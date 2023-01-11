//
//  ContentView.swift
//  kronor-test-app
//
//  Created by Jose-JORO on 2023-01-03.
//

import SwiftUI
import Apollo
import KronorComponents

struct ContentView: View {
    
    @State var resultText = "Touch button to see result"

    @State var sessionToken: String?

    @State var payment: String?

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

            if let sessionToken {
                SwishComponent(
                    sessionToken: sessionToken,
                    returnURL: URL(string: "io.kronortest://")!,
                    onPaymentFailure: {
                        self.sessionToken = nil
                        payment = "failed"
                    },
                    onPaymentSuccess: {paymentId in
                        self.sessionToken = nil
                        payment = paymentId
                    }
                )
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
