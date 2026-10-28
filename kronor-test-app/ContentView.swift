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

enum PaymentMethod: String, Identifiable {
    case unselected
    case swish
    case mobilepay
    case creditcard
    case applePay
    case avarda
    case paypal
    case vipps
    case bankTransfer
    case p24
    case fallback

    var id: PaymentMethod { self }
}

struct ContentView: View {

    @State var resultText = "Touch button to see result"

    @State var sessionToken: String?

    @State var payment: String?

    @State var paymentMethod = PaymentMethod.unselected

    func configuration(env: Kronor.Environment = .sandbox, sessionToken: String) -> ComponentConfiguration {
        .init(
            env: env,
            sessionToken: sessionToken,
            returnURL: URL(string: "io.kronortest://dummy")!
        )
    }

    @Sendable func handlePaymentResult(_ result: PaymentResult) async {
        await MainActor.run {
            self.sessionToken = nil
            self.paymentMethod = .unselected
            switch result {
            case .success(let paymentId):
                payment = paymentId
            case .failure(let error):
                payment = "failed: \(error)"
            }
        }
    }

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
                    if ApplePayComponent.canMakePayments() {
                        Text("Apple Pay").tag(PaymentMethod.applePay)
                    }
                    Text("Avarda").tag(PaymentMethod.avarda)
                    Text("PayPal").tag(PaymentMethod.paypal)
                    Text("Vipps").tag(PaymentMethod.vipps)
                    Text("BankTransfer").tag(PaymentMethod.bankTransfer)
                    Text("P24").tag(PaymentMethod.p24)
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
                        configuration: configuration(sessionToken: sessionToken),
                        paymentResultHandler: handlePaymentResult
                    )
                case .mobilepay:
                    MobilePayComponent(
                        configuration: configuration(sessionToken: sessionToken),
                        paymentResultHandler: handlePaymentResult
                    )
                case .creditcard:
                    CreditCardComponent(
                        configuration: configuration(sessionToken: sessionToken),
                        paymentResultHandler: handlePaymentResult
                    )
                case .applePay:
                    ApplePayComponent(
                        configuration: configuration(sessionToken: sessionToken),
                        merchantIdentifier: applePayMerchantIdentifier,
                        merchantName: "Kronor Test",
                        paymentResultHandler: handlePaymentResult
                    )
                case .avarda:
                    AvardaComponent(
                        configuration: configuration(sessionToken: sessionToken),
                        buyNowPayLaterProduct: .directInvoice,
                        paymentResultHandler: handlePaymentResult
                    )
                case .paypal:
                    PayPalComponent(
                        configuration: configuration(sessionToken: sessionToken),
                        paymentResultHandler: handlePaymentResult
                    )
                case .vipps:
                    VippsComponent(
                        configuration: configuration(env: .production, sessionToken: sessionToken),
                        paymentResultHandler: handlePaymentResult
                    )
                case .bankTransfer:
                    TrustlyComponent(
                        configuration: configuration(sessionToken: sessionToken),
                        paymentResultHandler: handlePaymentResult
                    )
                case .p24:
                    P24Component(
                        configuration: configuration(sessionToken: sessionToken),
                        paymentResultHandler: handlePaymentResult
                    )
                case .fallback:
                    FallbackComponent(
                        configuration: configuration(sessionToken: sessionToken),
                        paymentMethodName: "swish",
                        paymentResultHandler: handlePaymentResult
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
    var extensions : JSONObject
}
