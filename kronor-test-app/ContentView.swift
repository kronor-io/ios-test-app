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
    case paypal
    case fallback
    
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

            if sessionToken == nil {
                StartSession(sessionToken: $sessionToken) {
                    payment = nil
                }
            }
            
            if let payment {
                Spacer()
                Text("previous payment: \(payment)")
            }
            
            if sessionToken != nil && paymentMethod == .unselected {
                Picker("Payment Method", selection: $paymentMethod, content: {
                    Text("Select Payment method").tag(PaymentMethod.unselected)
                    Text("Swish").tag(PaymentMethod.swish)
                    Text("MobilePay").tag(PaymentMethod.mobilepay)
                    Text("Credit Card").tag(PaymentMethod.creditcard)
                    Text("PayPal").tag(PaymentMethod.paypal)
                    Text("Fallback (Swish)").tag(PaymentMethod.fallback)
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
                        returnURL: URL(string: "io.kronortest://")!,
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
                        returnURL: URL(string: "io.kronortest://dummy")!,
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
                        returnURL: URL(string: "io.kronortest://dummy")!,
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
                case .paypal:
                    PayPalComponent(
                        env: .sandbox,
                        sessionToken: sessionToken,
                        returnURL: URL(string: "io.kronortest://")!,
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
                case .fallback:
                    FallbackComponent(
                        env: .sandbox,
                        sessionToken: sessionToken,
                        paymentMethodName: "swish",
                        returnURL: URL(string: "io.kronortest://dummy")!,
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
