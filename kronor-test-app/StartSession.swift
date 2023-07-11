//
//  StartSession.swift
//  kronor-test-app
//
//  Created by Jose-JORO on 2023-01-03.
//

import SwiftUI
import KronorApi

struct StartSession: View {
    @Binding var sessionToken : String?
    @State var errorText :String?
    @State var rawAmount = ""
    @State var country = KronorApi.Country.dk
    @State var currency = KronorApi.SupportedCurrencyEnum.dkk

    var callback: () -> ()
    
    public init(sessionToken: Binding<String?>, callback: @escaping () -> ()) {
        self._sessionToken = sessionToken
        self.callback = callback
    }

    var body: some View {
        VStack {
            
            HStack {
                Label("Amount", systemImage: "dollarsign.circle")
                TextField("e.g. 100", text: $rawAmount)
                    .frame(width: 100.0)
                    .keyboardType(.decimalPad)
            }
            .padding()
            
            HStack {
                Label("Country", systemImage: "map")
                Picker("Country", selection: $country, content: {
                    Text("Denmark").tag(KronorApi.Country.dk)
                    Text("Sweden").tag(KronorApi.Country.se)
                    Text("Finland").tag(KronorApi.Country.fi)
                    Text("Iceland").tag(KronorApi.Country.is)
                }
                )
            }
            .padding()
            
                
            HStack {
                Label("Currency", systemImage: "coloncurrencysign.circle")
                Picker("Payment Method", selection: $currency, content: {
                    Text("DKK").tag(KronorApi.SupportedCurrencyEnum.dkk)
                    Text("SEK").tag(KronorApi.SupportedCurrencyEnum.sek)
                    Text("EUR").tag(KronorApi.SupportedCurrencyEnum.eur)
                    Text("ISK").tag(KronorApi.SupportedCurrencyEnum.isk)
                    }
                ).padding(.all)
            }
            
            
            Button(action: {
                if let amount = Double(rawAmount) {
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

func createPaymentSession(amount: Double, currency: KronorApi.SupportedCurrencyEnum, country: KronorApi.Country) async throws -> Result<String, APIError> {
    let expiry = Calendar.current.date(byAdding: .hour, value: 23, to: Date())!
    let idempotency = UUID().uuidString
    
    let input = KronorApi.PaymentSessionInput(
        additionalData: .some(KronorApi.PaymentSessionAdditionalData(
            email: "fancy@icloud.com",
            ip: "127.0.0.1",
            language: GraphQLEnum(KronorApi.Language.sv),
            name: "Fancy iPhone Owner",
            phoneNumber: "+4554367531"
        )),
        amount: Int(amount * 100),
        country: .some(GraphQLEnum.case(country)),
        currency: .some(GraphQLEnum.case(currency)),
        expiresAt: expiry.ISO8601Format(),
        idempotencyKey: idempotency,
        merchantReference: "ios-reference",
        message: "test payment"
    )

    return try await withCheckedThrowingContinuation {continuation in
        let client = makeGraphQLClientForTestMerchant()
        client.perform(mutation: KronorApi.NewPaymentSessionMutation(payment: input)) {data in
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
