//
//  StartSession.swift
//  kronor-test-app
//
//  Created by Jose-JORO on 2023-01-03.
//

import SwiftUI
import KronorMerchant
import AuthenticationServices

/// A payment session created on staging, ready to be paid.
struct PaymentSessionInfo {
    let token: String
    let amount: Int
    let currency: KronorMerchant.SupportedCurrencyEnum
    let country: KronorMerchant.Country
    let prefersKronorGateway: Bool

    var formattedAmount: String { formatAmount(amount, currency) }
}

/// Number of minor units in one major unit of `currency`.
func minorUnitDigits(_ currency: KronorMerchant.SupportedCurrencyEnum) -> Int {
    switch currency {
    case .isk, .huf: return 0
    default: return 2
    }
}

func formatAmount(_ minorUnits: Int, _ currency: KronorMerchant.SupportedCurrencyEnum) -> String {
    let digits = minorUnitDigits(currency)
    let major = Decimal(minorUnits) / pow(10, digits)
    return major.formatted(.number.precision(.fractionLength(digits))) + " " + currency.rawValue
}

extension KronorMerchant.Country {
    static let offered: [KronorMerchant.Country] = [.dk, .se, .no, .fi, .is, .nl, .pl]

    var name: String {
        Locale.current.localizedString(forRegionCode: rawValue) ?? rawValue
    }

    var flag: String {
        rawValue.unicodeScalars
            .compactMap { Unicode.Scalar(127397 + $0.value) }
            .map(String.init)
            .joined()
    }

    var defaultCurrency: KronorMerchant.SupportedCurrencyEnum {
        switch self {
        case .dk: return .dkk
        case .se: return .sek
        case .is: return .isk
        case .no: return .nok
        case .pl: return .pln
        default: return .eur
        }
    }
}

/// The form sections for logging in and creating a payment session.
struct StartSession: View {
    var onCreated: (PaymentSessionInfo) -> Void

    @ObservedObject private var auth = MerchantAuth.shared
    // Remembered between sessions and launches, to rerun the same test quickly.
    @AppStorage("startSession.amount") private var rawAmount = ""
    @AppStorage("startSession.country") private var country = KronorMerchant.Country.se
    @AppStorage("startSession.currency") private var currency = KronorMerchant.SupportedCurrencyEnum.sek
    @AppStorage("startSession.preferKronorGateway") private var preferKronorGateway = false
    @State private var isCreating = false
    @State private var errorText: String?

    private static let quickAmounts = ["1", "10", "99.50", "300.56"]
    private static let currencies: [KronorMerchant.SupportedCurrencyEnum] = [.sek, .dkk, .nok, .eur, .isk, .pln]

    /// The entered amount in minor units, if it's a valid positive amount
    /// for the chosen currency.
    private var amount: Int? {
        let normalized = rawAmount.replacingOccurrences(of: ",", with: ".")
        guard let major = Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX")),
              major > 0 else { return nil }
        let minor = major * pow(10, minorUnitDigits(currency))
        let whole = NSDecimalNumber(decimal: minor).intValue
        // Reject more decimals than the currency has.
        return Decimal(whole) == minor ? whole : nil
    }

    var body: some View {
        merchantSection

        Section {
            HStack {
                TextField("Amount", text: $rawAmount)
                    .keyboardType(.decimalPad)
                    .font(.title2.monospacedDigit())
                Text(currency.rawValue)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            HStack {
                ForEach(Self.quickAmounts, id: \.self) { quick in
                    Button(quick) { rawAmount = quick }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
            }
            Picker("Country", selection: $country) {
                ForEach(KronorMerchant.Country.offered, id: \.self) { country in
                    Text("\(country.flag) \(country.name)").tag(country)
                }
            }
            .onChange(of: country) { _, newCountry in
                currency = newCountry.defaultCurrency
            }
            Picker("Currency", selection: $currency) {
                ForEach(Self.currencies, id: \.self) { currency in
                    Text(currency.rawValue).tag(currency)
                }
            }
            Toggle("Prefer Kronor gateway", isOn: $preferKronorGateway)
        } header: {
            Text("Payment")
        } footer: {
            if let amount {
                Text("Sent as \(amount) minor units, split into two order lines so wallets like Apple Pay show an itemized sheet. The Kronor gateway is needed for Avarda.")
            } else {
                Text("Enter the amount in \(currency.rawValue), e.g. 300.56. The Kronor gateway is needed for Avarda.")
            }
        }

        Section {
            Button {
                Task { await createSession() }
            } label: {
                if isCreating {
                    ProgressView().tint(Color.kronorCream)
                } else {
                    Text(amount.map { "Create session for \(formatAmount($0, currency))" } ?? "Create payment session")
                }
            }
            .buttonStyle(.kronorPrimary)
            .disabled(!auth.isLoggedIn || amount == nil || isCreating)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }

        if let errorText {
            Section {
                Label {
                    Text(errorText).textSelection(.enabled)
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
                }
            }
        }
    }

    @ViewBuilder private var merchantSection: some View {
        Section("Merchant") {
            if auth.isLoggedIn {
                Label {
                    VStack(alignment: .leading) {
                        Text("Logged in to the staging portal")
                        if let summary = auth.accountSummary {
                            Text(summary)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                } icon: {
                    Image(systemName: "checkmark.seal.fill").foregroundStyle(Color.kronorGreen)
                }
                Button("Log out", role: .destructive) {
                    auth.logout()
                }
            } else {
                Text("Log in with your Kronor account and pick a sandbox merchant to create payment sessions with.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button {
                    Task { await login() }
                } label: {
                    Label("Log in to the staging portal", systemImage: "person.badge.key.fill")
                }
            }
        }
    }

    private func login() async {
        do {
            try await auth.login()
            errorText = nil
        } catch ASWebAuthenticationSessionError.canceledLogin {
        } catch {
            errorText = error.localizedDescription
        }
    }

    private func createSession() async {
        guard let amount else { return }
        isCreating = true
        defer { isCreating = false }
        do {
            let result = try await createPaymentSession(
                amount: amount,
                currency: currency,
                country: country,
                preferredGateway: preferKronorGateway ? .kronor : nil
            )
            switch result {
            case .failure(let apiError):
                let messages = apiError.errors.compactMap(\.message)
                errorText = messages.isEmpty ? "The session could not be created." : messages.joined(separator: "\n")
            case .success(let token):
                errorText = nil
                onCreated(PaymentSessionInfo(
                    token: token,
                    amount: amount,
                    currency: currency,
                    country: country,
                    prefersKronorGateway: preferKronorGateway
                ))
            }
        } catch let error as MerchantAuth.AuthError {
            errorText = error.localizedDescription
        } catch {
            errorText = "Network error: \(error.localizedDescription)"
        }
    }
}

func createPaymentSession(
    amount: Int,
    currency: KronorMerchant.SupportedCurrencyEnum,
    country: KronorMerchant.Country,
    preferredGateway: KronorMerchant.GatewayEnum? = nil
) async throws -> Result<String, APIError> {
    let expiry = Calendar.current.date(byAdding: .hour, value: 23, to: Date())!
    let idempotency = UUID().uuidString

    let input = KronorMerchant.PaymentSessionInput(
        additionalData: .some(KronorMerchant.PaymentSessionAdditionalData(
            email: "fancy@icloud.com",
            ip: "127.0.0.1",
            language: GraphQLEnum(KronorMerchant.Language.sv),
            name: "Fancy iPhone Owner",
            // Two items, so the itemization shows on the Apple Pay sheet.
            orderLines: .some([
                KronorMerchant.PurchaseOrderLineInput(
                   name: "Item 1",
                   pricePerItem: Int32(amount / 2),
                   quantity: 1,
                   reference: .some("ref-1"),
                   taxRate: 0,
                   totalAmount: Int32(amount / 2),
                   totalTaxAmount: 0
                ),
                KronorMerchant.PurchaseOrderLineInput(
                   name: "Item 2",
                   pricePerItem: Int32(amount - amount / 2),
                   quantity: 1,
                   reference: .some("ref-2"),
                   taxRate: 0,
                   totalAmount: Int32(amount - amount / 2),
                   totalTaxAmount: 0
                )
            ]),
            phoneNumber: "+4554367531",
            shippingAddress: .some(KronorMerchant.AddressInput(
                city: "Copenhagen",
                country: GraphQLEnum.case(country),
                email: "longemail@longerdomain.com",
                firstName: "hello",
                lastName: "world",
                phoneNumber: "+46740555111",
                postalCode: "2300",
                streetAddress: "Peter Bangs Vej 23"
            ))
        )),
        preferredGateway: preferredGateway.map { .some(GraphQLEnum.case($0)) } ?? .none,
        amount: Int32(amount),
        country: .some(GraphQLEnum.case(country)),
        currency: .some(GraphQLEnum.case(currency)),
        expiresAt: expiry.ISO8601Format(),
        idempotencyKey: idempotency,
        merchantReference: String("ios-\(Date().timeIntervalSinceReferenceDate)"),
        message: "test payment"
    )

    let client = try await makeGraphQLClientForTestMerchant()
    let response = try await client.perform(
        mutation: KronorMerchant.NewPaymentSessionMutation(payment: input)
    )

    if let data = response.data {
        return .success(data.newPaymentSession.token)
    }

    return .failure(
        APIError(errors: response.errors ?? [], extensions: response.extensions ?? [:])
    )
}
