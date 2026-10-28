//
//  ContentView.swift
//  kronor-test-app
//
//  Created by Jose-JORO on 2023-01-03.
//

import SwiftUI
import Apollo
import ApolloAPI
import Kronor
import KronorComponents

/// The Apple Pay merchant identifier registered in the Apple developer
/// account (team 8QB588R3S9). It must match the merchant identifier
/// configured for the staging merchant in Kronor (tenant.apple_pay_config)
/// and be listed in the app's in-app-payments entitlement.
let applePayMerchantIdentifier = "merchant.io.kronor.staging.payment-gateway"

enum PaymentMethod: String, CaseIterable, Identifiable, Hashable {
    case applePay
    case swish
    case mobilepay
    case vipps
    case creditcard
    case paypal
    case bankTransfer
    case p24
    case p24Blik
    case avarda
    case fallback

    var id: PaymentMethod { self }

    var title: String {
        switch self {
        case .applePay: "Apple Pay"
        case .swish: "Swish"
        case .mobilepay: "MobilePay"
        case .vipps: "Vipps"
        case .creditcard: "Credit Card"
        case .paypal: "PayPal"
        case .bankTransfer: "Bank Transfer"
        case .p24: "Przelewy24"
        case .p24Blik: "Przelewy24 · BLIK"
        case .avarda: "Avarda"
        case .fallback: "Fallback"
        }
    }

    var subtitle: String {
        switch self {
        case .applePay: "Native sheet, shows the order lines"
        case .swish: "Swedish mobile payments"
        case .mobilepay: "Danish and Finnish mobile payments"
        case .vipps: "Norwegian mobile payments · production"
        case .creditcard: "Card form in the embedded site"
        case .paypal: "PayPal checkout"
        case .bankTransfer: "Trustly bank transfer"
        case .p24: "Polish bank payments"
        case .p24Blik: "Only BLIK, via channelOverride"
        case .avarda: "Direct invoice · needs the Kronor gateway"
        case .fallback: "Generic component, opens Swish"
        }
    }

    var systemImage: String {
        switch self {
        case .applePay: "apple.logo"
        case .swish: "iphone.radiowaves.left.and.right"
        case .mobilepay: "iphone"
        case .vipps: "iphone.gen3"
        case .creditcard: "creditcard"
        case .paypal: "p.circle"
        case .bankTransfer: "building.columns"
        case .p24: "banknote"
        case .p24Blik: "number.square"
        case .avarda: "doc.text"
        case .fallback: "arrow.uturn.forward.circle"
        }
    }

    static var available: [PaymentMethod] {
        allCases.filter { $0 != .applePay || ApplePayComponent.canMakePayments() }
    }
}

/// The outcome of one payment attempt, kept for the "Recent payments" list.
struct PaymentAttempt: Identifiable {
    let id = UUID()
    let method: PaymentMethod
    let amount: String
    let date = Date()
    let result: PaymentResult
}

struct ContentView: View {
    @State private var session: PaymentSessionInfo?
    @State private var method: PaymentMethod?
    @State private var attempts: [PaymentAttempt] = []

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    KronorHeader()
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 4, bottom: 0, trailing: 4))

                if let latest = attempts.first {
                    Section {
                        AttemptRow(attempt: latest, prominent: true)
                    }
                }

                if let session {
                    sessionSections(session)
                } else {
                    StartSession { session = $0 }
                }

                if attempts.count > 1 {
                    Section("Earlier payments") {
                        ForEach(attempts.dropFirst()) { attempt in
                            AttemptRow(attempt: attempt, prominent: false)
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $method) { method in
                if let session {
                    paymentScreen(method: method, session: session)
                }
            }
        }
    }

    @ViewBuilder private func sessionSections(_ session: PaymentSessionInfo) -> some View {
        Section {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.formattedAmount)
                        .font(.title.bold().monospacedDigit())
                    Text("\(session.country.flag) \(session.country.name)" + (session.prefersKronorGateway ? " · Kronor gateway" : ""))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Cancel", role: .destructive) {
                    self.session = nil
                }
                .buttonStyle(.borderless)
            }
        } header: {
            Text("Session ready")
        }

        Section("Pay with") {
            ForEach(PaymentMethod.available) { method in
                Button {
                    self.method = method
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: method.systemImage)
                            .font(.title3)
                            .foregroundStyle(Color.kronorCream)
                            .frame(width: 40, height: 40)
                            .background(Color.kronorGreen, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(method.title)
                                .foregroundStyle(.primary)
                            Text(method.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }

    private func paymentScreen(method: PaymentMethod, session: PaymentSessionInfo) -> some View {
        component(method: method, sessionToken: session.token) { result in
            await MainActor.run {
                attempts.insert(
                    PaymentAttempt(method: method, amount: session.formattedAmount, result: result),
                    at: 0
                )
                self.method = nil
                self.session = nil
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle("\(method.title) · \(session.formattedAmount)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func configuration(env: Kronor.Environment = .sandbox, sessionToken: String) -> ComponentConfiguration {
        .init(
            env: env,
            sessionToken: sessionToken,
            returnURL: URL(string: "io.kronortest://dummy")!
        )
    }

    @ViewBuilder private func component(
        method: PaymentMethod,
        sessionToken: String,
        handler: @escaping @Sendable (PaymentResult) async -> Void
    ) -> some View {
        switch method {
        case .swish:
            SwishComponent(configuration: configuration(sessionToken: sessionToken), paymentResultHandler: handler)
        case .mobilepay:
            MobilePayComponent(configuration: configuration(sessionToken: sessionToken), paymentResultHandler: handler)
        case .creditcard:
            CreditCardComponent(configuration: configuration(sessionToken: sessionToken), paymentResultHandler: handler)
        case .applePay:
            ApplePayComponent(
                configuration: configuration(sessionToken: sessionToken),
                merchantIdentifier: applePayMerchantIdentifier,
                merchantName: "Kronor Test",
                paymentResultHandler: handler
            )
        case .avarda:
            AvardaComponent(
                configuration: configuration(sessionToken: sessionToken),
                buyNowPayLaterProduct: .directInvoice,
                paymentResultHandler: handler
            )
        case .paypal:
            PayPalComponent(configuration: configuration(sessionToken: sessionToken), paymentResultHandler: handler)
        case .vipps:
            VippsComponent(configuration: configuration(env: .production, sessionToken: sessionToken), paymentResultHandler: handler)
        case .bankTransfer:
            TrustlyComponent(configuration: configuration(sessionToken: sessionToken), paymentResultHandler: handler)
        case .p24:
            P24Component(configuration: configuration(sessionToken: sessionToken), paymentResultHandler: handler)
        case .p24Blik:
            P24Component(
                configuration: configuration(sessionToken: sessionToken),
                channelOverride: .blik,
                paymentResultHandler: handler
            )
        case .fallback:
            FallbackComponent(
                configuration: configuration(sessionToken: sessionToken),
                paymentMethodName: "swish",
                paymentResultHandler: handler
            )
        }
    }
}

struct AttemptRow: View {
    let attempt: PaymentAttempt
    let prominent: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: succeeded ? "checkmark.circle.fill" : "xmark.octagon.fill")
                .font(prominent ? .title : .title3)
                .foregroundStyle(succeeded ? Color.kronorGreen : .red)
            VStack(alignment: .leading, spacing: 4) {
                Text(succeeded ? "Paid \(attempt.amount)" : "Payment failed")
                    .font(prominent ? .headline : .body)
                Text("\(attempt.method.title) · \(attempt.date.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(detail)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
        }
        .padding(.vertical, prominent ? 4 : 0)
        .contextMenu {
            Button("Copy", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = detail
            }
        }
    }

    private var succeeded: Bool {
        if case .success = attempt.result { true } else { false }
    }

    /// The payment id on success, the error otherwise.
    private var detail: String {
        switch attempt.result {
        case .success(let paymentId): paymentId
        case .failure(let error): String(describing: error)
        }
    }
}

#Preview {
    ContentView()
}

struct APIError: Error {
    var errors : [GraphQLError]
    var extensions : JSONObject
}
