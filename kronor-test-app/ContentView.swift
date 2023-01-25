//
//  ContentView.swift
//  kronor-test-app
//
//  Created by Jose-JORO on 2023-01-03.
//

import SwiftUI
import Apollo
import KronorComponents

enum PaymentMethod: String, Identifiable {
    case unselected
    case swish
    case mobilepay
    case creditcard
    
    var id: PaymentMethod { self }
}

struct ContentView: View {
    
    @State var resultText = "Touch button to see result"

    @State var sessionToken: String?

    @State var payment: String?
    
    @State var paymentMethod = PaymentMethod.unselected

    var body: some View {
        VStack {
            Spacer()

            if sessionToken == nil || payment != nil {
                StartSession(sessionToken: $sessionToken) {
                    payment = nil
                }

                if let payment {
                    Spacer()
                    Text("previous payment: \(payment)")
                }
            }
            
            if sessionToken != nil && paymentMethod == .unselected {
                Picker("Payment Method", selection: $paymentMethod, content: {
                    Text("Select Payment method").tag(PaymentMethod.unselected)
                    Text("Swish").tag(PaymentMethod.swish)
                    Text("MobilePay").tag(PaymentMethod.mobilepay)
                    Text("Credit Card").tag(PaymentMethod.creditcard)
                })
            }

            if let sessionToken {
                switch paymentMethod {
                case .unselected:
                    Text("select method to continue")
                        .padding(.vertical)
                case .swish:
                    SwishComponent(
                        env: .sandbox,
                        sessionToken: sessionToken,
                        returnURL: URL(string: "https://google.com")!,
                        onPaymentFailure: {
                            self.sessionToken = nil
                            payment = "failed"
                        },
                        onPaymentSuccess: {paymentId in
                            self.sessionToken = nil
                            self.paymentMethod = .unselected
                            payment = paymentId
                        }
                    )
                case .mobilepay:
                    MobilePayComponent(
                        env: .sandbox,
                        sessionToken: sessionToken,
                        returnURL: URL(string: "https://google.com")!,
                        onPaymentFailure: {
                            self.sessionToken = nil
                            self.paymentMethod = .unselected
                            payment = "failed"
                        },
                        onPaymentSuccess: {paymentId in
                            self.sessionToken = nil
                            payment = paymentId
                        }
                    )
                case .creditcard:
                    CreditCardComponent(
                        env: .sandbox,
                        sessionToken: sessionToken,
                        returnURL: URL(string: "https://google.com")!,
                        onPaymentFailure: {
                            self.sessionToken = nil
                            self.paymentMethod = .unselected
                            payment = "failed"
                        },
                        onPaymentSuccess: {paymentId in
                            self.sessionToken = nil
                            payment = paymentId
                        }
                    )
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct APIError: Error {
    var errors : [GraphQLError]
    var extensions : [String : AnyHashable]
}
