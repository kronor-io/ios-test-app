//
//  Client.swift
//  kronor-test-app
//
//  Created by Jose-JORO on 2023-01-03.
//

import Foundation
import Apollo
import KronorApi
import AuthenticationServices
import CryptoKit
import Network
import UIKit

func makeGraphQLClientForTestMerchant() async throws -> ApolloClient {
    let token = try await MerchantAuth.shared.freshToken()
    return KronorApi.makeGraphQLClient(env: .sandbox, token: token)
}

/// Logs in to the staging portal the same way docs.kronor.io does: OAuth2
/// authorization code + PKCE with the public `kronor-docs` client, which
/// hands out short-lived merchant-backend tokens for sandbox and test
/// merchants only.
///
/// That client only accepts web redirect URIs, so the app answers
/// http://localhost:8000/oauth-callback.html itself and bounces the browser
/// on to its own URL scheme, where the login sheet picks the code up.
@MainActor
final class MerchantAuth: NSObject, ObservableObject {
    static let shared = MerchantAuth()

    private let clientId = "kronor-docs"
    private let authorizeURL = URL(string: "https://staging.kronor.io/portal/oauth/authorize")!
    private let tokenURL = URL(string: "https://staging.kronor.io/portal/oauth/token")!
    private let redirectURI = "http://localhost:8000/oauth-callback.html"
    private let callbackScheme = "io.kronortest"

    private enum Keys {
        static let accessToken = "merchantAuth.accessToken"
        static let expiresAt = "merchantAuth.expiresAt"
        static let refreshToken = "merchantAuth.refreshToken"
    }

    enum AuthError: LocalizedError {
        case notLoggedIn
        case invalidCallback
        case tokenRequest(String)

        var errorDescription: String? {
            switch self {
            case .notLoggedIn: "Log in to the staging portal first."
            case .invalidCallback: "Invalid login callback, please try logging in again."
            case .tokenRequest(let message): "Token request failed: \(message)"
            }
        }
    }

    @Published private(set) var isLoggedIn: Bool

    private let defaults = UserDefaults.standard
    private var session: ASWebAuthenticationSession?
    private var redirector: LoopbackRedirector?
    private var refreshInFlight: Task<String, Error>?

    private override init() {
        isLoggedIn = defaults.string(forKey: Keys.refreshToken) != nil
        super.init()
    }

    func login() async throws {
        let verifier = Self.randomToken()
        let state = Self.randomToken()

        var components = URLComponents(url: authorizeURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: "graphql offline_access"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "code_challenge", value: Self.pkceChallenge(verifier)),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
        ]

        let redirector = LoopbackRedirector(port: 8000, scheme: callbackScheme)
        redirector.start()
        self.redirector = redirector
        defer {
            redirector.stop()
            self.redirector = nil
            self.session = nil
        }

        let callback: URL = try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: components.url!,
                callback: .customScheme(callbackScheme)
            ) { url, error in
                if let url {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: error ?? AuthError.invalidCallback)
                }
            }
            // Reuse the portal login from Safari, if there is one.
            session.prefersEphemeralWebBrowserSession = false
            session.presentationContextProvider = self
            self.session = session
            session.start()
        }

        let params = URLComponents(url: callback, resolvingAgainstBaseURL: false)?.queryItems ?? []
        func param(_ name: String) -> String? { params.first { $0.name == name }?.value }
        if let error = param("error") {
            throw AuthError.tokenRequest(param("error_description") ?? error)
        }
        guard let code = param("code"), param("state") == state else {
            throw AuthError.invalidCallback
        }

        try await tokenRequest([
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURI,
            "code_verifier": verifier,
        ])
    }

    func logout() {
        [Keys.accessToken, Keys.expiresAt, Keys.refreshToken].forEach(defaults.removeObject(forKey:))
        isLoggedIn = false
    }

    /// A usable access token, refreshed when it's within five minutes of expiring.
    func freshToken() async throws -> String {
        if let token = defaults.string(forKey: Keys.accessToken),
           Date.now.timeIntervalSince1970 < defaults.double(forKey: Keys.expiresAt) - 5 * 60 {
            return token
        }
        // Refresh tokens rotate and reusing one revokes the chain, so only
        // ever have one refresh in flight.
        if let refreshInFlight {
            return try await refreshInFlight.value
        }
        guard let refreshToken = defaults.string(forKey: Keys.refreshToken) else {
            throw AuthError.notLoggedIn
        }
        let task = Task {
            defer { refreshInFlight = nil }
            return try await tokenRequest([
                "grant_type": "refresh_token",
                "refresh_token": refreshToken,
            ])
        }
        refreshInFlight = task
        return try await task.value
    }

    @discardableResult
    private func tokenRequest(_ params: [String: String]) async throws -> String {
        struct TokenResponse: Decodable {
            let access_token: String
            let expires_in: Double
            let refresh_token: String?
        }
        struct ErrorResponse: Decodable {
            let error: String
            let error_description: String?
        }

        var form = URLComponents()
        form.queryItems = params.merging(["client_id": clientId]) { $1 }
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = form.percentEncodedQuery?.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            let error = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            if error?.error == "invalid_grant" {
                logout()
            }
            throw AuthError.tokenRequest(
                error.map { $0.error_description ?? $0.error } ?? String(decoding: data, as: UTF8.self)
            )
        }

        let tokens = try JSONDecoder().decode(TokenResponse.self, from: data)
        defaults.set(tokens.access_token, forKey: Keys.accessToken)
        defaults.set(Date.now.timeIntervalSince1970 + tokens.expires_in, forKey: Keys.expiresAt)
        if let refreshToken = tokens.refresh_token {
            defaults.set(refreshToken, forKey: Keys.refreshToken)
        }
        isLoggedIn = true
        return tokens.access_token
    }

    private static func base64URL(_ data: some DataProtocol) -> String {
        Data(data).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private static func randomToken() -> String {
        base64URL(SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) })
    }

    private static func pkceChallenge(_ verifier: String) -> String {
        base64URL(Data(SHA256.hash(data: Data(verifier.utf8))))
    }
}

extension MerchantAuth: ASWebAuthenticationPresentationContextProviding {
    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first { $0.isKeyWindow } ?? ASPresentationAnchor()
        }
    }
}

/// Answers every request on localhost with a redirect to the same path and
/// query under `scheme`, so the login sheet sees the OAuth callback.
private final class LoopbackRedirector {
    private let listeners: [NWListener]
    private let scheme: String

    init(port: UInt16, scheme: String) {
        self.scheme = scheme
        // Safari may resolve localhost to either loopback address.
        listeners = ["127.0.0.1", "::1"].compactMap { host in
            let parameters = NWParameters.tcp
            parameters.allowLocalEndpointReuse = true
            parameters.requiredLocalEndpoint = .hostPort(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: port)!)
            return try? NWListener(using: parameters)
        }
    }

    func start() {
        for listener in listeners {
            listener.newConnectionHandler = { [scheme] connection in
                connection.start(queue: .main)
                connection.receive(minimumIncompleteLength: 1, maximumLength: 16 * 1024) { data, _, _, _ in
                    // "GET /oauth-callback.html?code=...&state=... HTTP/1.1"
                    let requestLine = data.flatMap { String(data: $0, encoding: .utf8) }?
                        .components(separatedBy: "\r\n").first ?? ""
                    let target = requestLine.split(separator: " ").dropFirst().first.map(String.init) ?? "/"
                    let response = "HTTP/1.1 302 Found\r\nLocation: \(scheme)://localhost\(target)\r\nContent-Length: 0\r\nConnection: close\r\n\r\n"
                    connection.send(content: Data(response.utf8), completion: .contentProcessed { _ in
                        connection.cancel()
                    })
                }
            }
            listener.start(queue: .main)
        }
    }

    func stop() {
        listeners.forEach { $0.cancel() }
    }
}
