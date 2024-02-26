//
//  StartSession.swift
//  kronor-test-app
//
//  Created by Jose-JORO on 2023-01-03.
//

import SwiftUI
import KronorMerchant

struct StartSession: View {
    @Binding var sessionToken : String?
    @State var errorText :String?
    @State var rawAmount = ""
    @State var country =  KronorMerchant.Country.dk
    @State var currency = KronorMerchant.SupportedCurrencyEnum.dkk

    var callback: () -> ()
    
    public init(sessionToken: Binding<String?>, callback: @escaping () -> ()) {
        self._sessionToken = sessionToken
        self.callback = callback
    }

    var body: some View {
        VStack {
            
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
                }
                )
            }
            .padding()
            
                
            HStack {
                Label("Currency", systemImage: "coloncurrencysign.circle")
                Picker("Payment Method", selection: $currency, content: {
                    Text("DKK").tag(KronorMerchant.SupportedCurrencyEnum.dkk)
                    Text("SEK").tag(KronorMerchant.SupportedCurrencyEnum.sek)
                    Text("EUR").tag(KronorMerchant.SupportedCurrencyEnum.eur)
                    Text("ISK").tag(KronorMerchant.SupportedCurrencyEnum.isk)
                    Text("NOK").tag(KronorMerchant.SupportedCurrencyEnum.nok)
                    }
                ).padding(.all)
            }
            
            
            Button(action: {
                if let amount = Int(rawAmount) {
                    Task {
                        do {
                            let result = try await createPaymentSession(amount: amount, currency: currency, country: country)
                            switch result {
                            case .failure(let apiErrors):
                                self.errorText = "Errors: \(apiErrors.errors) \n Extensions: \(apiErrors.extensions)"
                            case .success(let token):
                                self.sessionToken = token
                                self.callback()
                            }
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

func createPaymentSession(amount: Int, currency: KronorMerchant.SupportedCurrencyEnum, country: KronorMerchant.Country) async throws -> Result<String, APIError> {
    let expiry = Calendar.current.date(byAdding: .hour, value: 23, to: Date())!
    let idempotency = UUID().uuidString
    
    let input = KronorMerchant.PaymentSessionInput(
        additionalData: .some(KronorMerchant.PaymentSessionAdditionalData(
            email: "fancy@icloud.com",
            ip: "127.0.0.1",
            language: GraphQLEnum(KronorMerchant.Language.sv),
            name: "Fancy iPhone Owner",
            orderLines: .some([
                KronorMerchant.PurchaseOrderLineInput(
                   name: "Item 1",
                   pricePerItem: amount,
                   quantity: 1,
                   reference: .some("ref-1"),
                   taxRate: 0,
                   totalAmount: amount,
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
        amount: amount,
        country: .some(GraphQLEnum.case(country)),
        currency: .some(GraphQLEnum.case(currency)),
        expiresAt: expiry.ISO8601Format(),
        idempotencyKey: idempotency,
        merchantReference: String("ios-\(Date().timeIntervalSinceReferenceDate)"),
        message: "test payment"
    )

    return try await withCheckedThrowingContinuation {continuation in
        let client = makeGraphQLClientForTestMerchant()
        client.perform(mutation: KronorMerchant.NewPaymentSessionMutation(payment: input)) {data in
            switch data {
            case .failure(let error):
                continuation.resume(throwing: error)
            case .success(let result):
                if let data = result.data {
                    continuation.resume(returning: .success(data.newPaymentSession.token))
                } else {
                    continuation.resume(returning: .failure(
                        APIError(
                            errors: result.errors ?? [], extensions: result.extensions ?? [:])
                        )
                    )
                }
            }
        }
    }
}
