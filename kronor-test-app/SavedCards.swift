//
//  SavedCards.swift
//  kronor-test-app
//

import SwiftUI
import WebKit
import KronorMerchant

/// The customer that payment sessions and the saved-card screens act for.
/// Cards saved during a checkout hang off this reference, and the saved-card
/// components only ever see the cards of the reference their session was made
/// for, so both sides must use the same one.
let customerReferenceKey = "savedCards.customerReference"

/// The web components the payment gateway exports for managing saved cards,
/// outside of any checkout.
enum SavedCardsComponent: String, CaseIterable, Identifiable, Hashable {
    /// The full list: rename, set as default, remove and add cards.
    case list = "savedCards"
    /// The default card on its own, read-only.
    case defaultCard = "defaultSavedCard"

    var id: SavedCardsComponent { self }

    var title: String {
        switch self {
        case .list: "Manage saved cards"
        case .defaultCard: "Default card"
        }
    }

    var subtitle: String {
        switch self {
        case .list: "kronor.savedCards · edit, remove and add"
        case .defaultCard: "kronor.defaultSavedCard · read-only"
        }
    }

    var systemImage: String {
        switch self {
        case .list: "creditcard.and.123"
        case .defaultCard: "star.square"
        }
    }
}

/// Creates a customer session for `customerReference` and shows `component`
/// with its token in a web view, the way a merchant's account page would
/// embed it.
struct SavedCardsScreen: View {
    let component: SavedCardsComponent

    @AppStorage(customerReferenceKey) private var customerReference = "ios-test-customer"
    @AppStorage("startSession.country") private var country = KronorMerchant.Country.se
    @AppStorage("startSession.currency") private var currency = KronorMerchant.SupportedCurrencyEnum.sek
    @State private var token: String?
    @State private var errorText: String?

    var body: some View {
        Group {
            if let token {
                SavedCardsWebView(component: component, token: token)
                    .ignoresSafeArea(edges: .bottom)
            } else if let errorText {
                ContentUnavailableView {
                    Label("No customer session", systemImage: "exclamationmark.triangle.fill")
                } description: {
                    Text(errorText).textSelection(.enabled)
                } actions: {
                    Button("Try again") { Task { await start() } }
                }
            } else {
                ProgressView("Creating customer session…")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(component.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text(component.title).font(.headline)
                    Text(customerReference).font(.caption).foregroundStyle(.secondary)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("New session", systemImage: "arrow.clockwise") {
                    Task { await start() }
                }
                .disabled(token == nil && errorText == nil)
            }
        }
        .task { await start() }
    }

    private func start() async {
        token = nil
        errorText = nil
        do {
            switch try await createCustomerSession(
                customerReference: customerReference,
                country: country,
                currency: currency
            ) {
            case .success(let token):
                self.token = token
            case .failure(let apiError):
                let messages = apiError.errors.compactMap(\.message)
                errorText = messages.isEmpty ? "The customer session could not be created." : messages.joined(separator: "\n")
            }
        } catch let error as MerchantAuth.AuthError {
            errorText = error.localizedDescription
        } catch {
            errorText = "Network error: \(error.localizedDescription)"
        }
    }
}

/// Hosts one of the gateway's saved-card components.
///
/// The page is loaded with the gateway as its base URL, so it has the
/// gateway's origin: the bundle is imported same-origin, and the add-card form,
/// which the list frames from the gateway, passes its `frame-ancestors 'self'`.
struct SavedCardsWebView: UIViewRepresentable {
    let component: SavedCardsComponent
    let token: String

    private static let gatewayURL = URL(string: "https://payment-gateway.staging.kronor.io/")!

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        // Debug it from Safari's Develop menu.
        webView.isInspectable = true
        // The component's dialogs scroll inside their own panel. Without this,
        // a swipe that reaches the panel's end carries on into the web view,
        // which bounces the page behind the dialog instead.
        webView.scrollView.bounces = false
        webView.loadHTMLString(html, baseURL: Self.gatewayURL)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    private var html: String {
        // JSON-encoded, so the values land in the script as string literals.
        let options = try! JSONSerialization.data(
            withJSONObject: ["function": component.rawValue, "authToken": token]
        )
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <!-- maximum-scale stops WebKit zooming in on focused fields, which
                 left the page zoomed and scrolled sideways after the 3DS OTP. -->
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
            <style>
                /* Keeps scrolling inside the component's dialogs from chaining
                   out to the page underneath them. */
                html, body { overscroll-behavior: none; }
                body { margin: 0; padding: 16px; font-family: -apple-system, sans-serif; background: #fff; }
                #hint { font-size: 13px; color: #b00020; white-space: pre-wrap; }
            </style>
        </head>
        <body>
            <div id="hint"></div>
            <div id="container"></div>
            <script>
                const options = \(String(decoding: options, as: UTF8.self))
                const $hint = document.querySelector('#hint')
                window.addEventListener('error', event => { $hint.innerText += `${event.message}\\n` })
                window.addEventListener('unhandledrejection', event => { $hint.innerText += `${event.reason}\\n` })
                import('\(Self.gatewayURL.absoluteString)esm/index.js')
                    .then(kronor => kronor[options.function]({
                        container: document.querySelector('#container'),
                        authToken: options.authToken
                    }))
                    .catch(error => { $hint.innerText = `Failed to load the component bundle: ${error}` })
            </script>
        </body>
        </html>
        """
    }
}

func createCustomerSession(
    customerReference: String,
    country: KronorMerchant.Country,
    currency: KronorMerchant.SupportedCurrencyEnum
) async throws -> Result<String, APIError> {
    let expiry = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!

    let input = KronorMerchant.CustomerSessionInput(
        country: .some(GraphQLEnum.case(country)),
        currency: .some(GraphQLEnum.case(currency)),
        customerReference: customerReference,
        email: "fancy@icloud.com",
        expiresAt: expiry.ISO8601Format(),
        idempotencyKey: UUID().uuidString,
        ip: "127.0.0.1",
        language: GraphQLEnum(KronorMerchant.Language.en),
        merchantReference: "ios-customer-\(Int(Date().timeIntervalSinceReferenceDate))",
        name: "Fancy iPhone Owner",
        phoneNumber: "+4554367531"
    )

    let client = try await makeGraphQLClientForTestMerchant()
    let response = try await client.perform(
        mutation: KronorMerchant.NewCustomerSessionMutation(sessionInfo: input)
    )

    if let data = response.data {
        return .success(data.newCustomerSession.token)
    }

    return .failure(
        APIError(errors: response.errors ?? [], extensions: response.extensions ?? [:])
    )
}
