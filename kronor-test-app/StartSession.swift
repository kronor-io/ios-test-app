//
//  StartSession.swift
//  kronor-test-app
//
//  Created by Jose-JORO on 2023-01-03.
//

import SwiftUI
import KronorMerchant
import AuthenticationServices

struct StartSession: View {
    @Binding var sessionToken : String?
    @State var errorText :String?
    @State var rawAmount = ""
    @State var country =  KronorMerchant.Country.dk
    @State var currency = KronorMerchant.SupportedCurrencyEnum.dkk
    @State var preferKronorGateway = false
    @ObservedObject var auth = MerchantAuth.shared

    var callback: () -> ()
    
    private func defaultCurrency(for country: KronorMerchant.Country) -> KronorMerchant.SupportedCurrencyEnum {
        switch country {
        case .dk: return .dkk
        case .se: return .sek
        case .fi: return .eur
        case .is: return .isk
        case .no: return .nok
        case .pl: return .pln
        case .nl: return .eur
        default: return .eur
        }
    }
    
    public init(sessionToken: Binding<String?>, callback: @escaping () -> ()) {
        self._sessionToken = sessionToken
        self.callback = callback
    }

    var body: some View {
        VStack {

            if auth.isLoggedIn {
                Button("Log out of the staging portal") {
                    auth.logout()
                }
            } else {
                Button("Log in to the staging portal") {
                    Task {
                        do {
                            try await auth.login()
                            errorText = nil
                        } catch ASWebAuthenticationSessionError.canceledLogin {
                        } catch {
                            errorText = error.localizedDescription
                        }
                    }
                }
            }

            HStack {
                Label("Amount (minor units)", systemImage: "dollarsign.circle")
                TextField("e.g. 100 for 1 DKK", text: $rawAmount)
                    .frame(width: 100.0)
                    .keyboardType(.numberPad)
            }
            .padding()
            
            HStack {
                Label("Country", systemImage: "map")
                Picker("Country", selection: $country, content: {
                    Text("Denmark").tag(KronorMerchant.Country.dk)
                    Text("Sweden").tag(KronorMerchant.Country.se)
                    Text("Finland").tag(KronorMerchant.Country.fi)
                    Text("Iceland").tag(KronorMerchant.Country.is)
                    Text("Norway").tag(KronorMerchant.Country.no)
                    Text("Netherlands").tag(KronorMerchant.Country.nl)
                    Text("Poland").tag(KronorMerchant.Country.pl)
                }
                )
            }
            .padding()
            .onChange(of: country) { _, newCountry in
                currency = defaultCurrency(for: newCountry)
            }
            
                
            HStack {
                Label("Currency", systemImage: "coloncurrencysign.circle")
                Picker("Payment Method", selection: $currency, content: {
                    Text("DKK").tag(KronorMerchant.SupportedCurrencyEnum.dkk)
                    Text("SEK").tag(KronorMerchant.SupportedCurrencyEnum.sek)
                    Text("EUR").tag(KronorMerchant.SupportedCurrencyEnum.eur)
                    Text("ISK").tag(KronorMerchant.SupportedCurrencyEnum.isk)
                    Text("NOK").tag(KronorMerchant.SupportedCurrencyEnum.nok)
                    Text("PLN").tag(KronorMerchant.SupportedCurrencyEnum.pln)
                    }
                ).padding(.all)
            }

            Toggle("Prefer Kronor gateway (needed for Avarda)", isOn: $preferKronorGateway)
                .padding(.horizontal)

            Button(action: {
                if let amount = Int(rawAmount) {
                    Task {
                        do {
                            let result = try await createPaymentSession(
                                amount: amount,
                                currency: currency,
                                country: country,
                                preferredGateway: preferKronorGateway ? .kronor : nil
                            )
                            switch result {
                            case .failure(let apiErrors):
                                self.errorText = "Errors: \(apiErrors.errors) \n Extensions: \(apiErrors.extensions)"
                            case .success(let token):
                                self.sessionToken = token
                                self.callback()
                            }
                        } catch let error as MerchantAuth.AuthError {
                            self.errorText = error.localizedDescription
                        } catch {
                            self.errorText = "Network error: \(error)"
                        }
                    }
                }
            })
            {
                Text("Start Session")
            }
            .padding(.top)
        }
        .onAppear {
            currency = defaultCurrency(for: country)
        }
        
        if let errorText {
            Spacer()
            Text(errorText)
        }
    }
}
struct StartSession_Previews: PreviewProvider {
    @State private static var b :String?
    
    static var previews: some View {
        StartSession(sessionToken: $b) {
            
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

