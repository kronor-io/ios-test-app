// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension KronorMerchant {
  /// Arguments for creating a new payment session.
  nonisolated struct PaymentSessionInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      additionalData: GraphQLNullable<PaymentSessionAdditionalData> = nil,
      allowExecutionDate: GraphQLNullable<Bool> = nil,
      amount: Int32,
      country: GraphQLNullable<GraphQLEnum<Country>> = nil,
      currency: GraphQLNullable<GraphQLEnum<SupportedCurrencyEnum>> = nil,
      expiresAt: String,
      idempotencyKey: String,
      merchantReference: String,
      merchantReference2: GraphQLNullable<String> = nil,
      message: String,
      preferredGateway: GraphQLNullable<GraphQLEnum<GatewayEnum>> = nil,
      saveCardDetails: GraphQLNullable<Bool> = nil
    ) {
      __data = InputDict([
        "additionalData": additionalData,
        "allowExecutionDate": allowExecutionDate,
        "amount": amount,
        "country": country,
        "currency": currency,
        "expiresAt": expiresAt,
        "idempotencyKey": idempotencyKey,
        "merchantReference": merchantReference,
        "merchantReference2": merchantReference2,
        "message": message,
        "preferredGateway": preferredGateway,
        "saveCardDetails": saveCardDetails
      ])
    }

    /// Additional data about the customer attempting the payment.
    public var additionalData: GraphQLNullable<PaymentSessionAdditionalData> {
      get { __data["additionalData"] }
      set { __data["additionalData"] = newValue }
    }

    /// Whether setting an execution date is allowed for payments in this session.
    public var allowExecutionDate: GraphQLNullable<Bool> {
      get { __data["allowExecutionDate"] }
      set { __data["allowExecutionDate"] = newValue }
    }

    /// The amount the customer pays in minor units.
    /// So 100,56 kr would be 10056
    public var amount: Int32 {
      get { __data["amount"] }
      set { __data["amount"] = newValue }
    }

    /// The country where the payment is taking place.
    /// Example: `SE`, `DK`, `NO`, `IS`, `FI`
    public var country: GraphQLNullable<GraphQLEnum<Country>> {
      get { __data["country"] }
      set { __data["country"] = newValue }
    }

    /// When `currency` is not set, it defaults to the merchant's default currency.
    ///
    /// When no payment method is available for the given currency, then
    /// `newPaymentSession` fails with an error. Similarly, attempting to
    /// create a payment with a payment method that is not available for
    /// the given currency also results in an error.
    public var currency: GraphQLNullable<GraphQLEnum<SupportedCurrencyEnum>> {
      get { __data["currency"] }
      set { __data["currency"] = newValue }
    }

    /// Session expiry timestamp in ISO8601 format.
    /// E.g. '1970-01-01T00:00:00Z'
    /// Max is 24 hrs from creation of session.
    public var expiresAt: String {
      get { __data["expiresAt"] }
      set { __data["expiresAt"] = newValue }
    }

    /// Idempotency key is required to prevent double processing a request.
    /// It is recommended to use a deterministic unique value, such as the combination of
    /// the order id and the customer id. Avoid using time-based values.
    /// Only alphanumeric character and the following are allowed:
    /// - "-"
    /// - "_"
    /// - "."
    /// - ","
    /// - "["
    /// - "]"
    /// - "+"
    ///
    /// Max length: 64.
    public var idempotencyKey: String {
      get { __data["idempotencyKey"] }
      set { __data["idempotencyKey"] = newValue }
    }

    /// Merchant's own internal reference that may help the
    /// merchant in identifying this payment. These have to
    /// be globally unique but they should be reused for retrying
    /// a payment.
    ///
    /// Max length: 64.
    public var merchantReference: String {
      get { __data["merchantReference"] }
      set { __data["merchantReference"] = newValue }
    }

    /// An additional merchant's reference that may help the
    /// merchant in identifying this payment. These need not be
    /// be unique. Can store any information.
    ///
    /// Max length: 1000.
    public var merchantReference2: GraphQLNullable<String> {
      get { __data["merchantReference2"] }
      set { __data["merchantReference2"] = newValue }
    }

    /// A message to show to the customer. It could be an order id or a reference.
    /// Only alphanumeric, Swedish characters, and the following are allowed:
    /// - ':'
    /// - ';'
    /// - '.'
    /// - ','
    /// - '?'
    /// - '!'
    /// - '('
    /// - ')'
    /// - '”'
    /// - '"'
    /// - ' '
    ///
    /// Max length: 50.
    public var message: String {
      get { __data["message"] }
      set { __data["message"] = newValue }
    }

    /// The preferred gateway to use for this payment session.
    /// Only "KRONOR" is supported at the moment.
    /// Leave empty if you don't know why you need this. Talk to us before using this.
    public var preferredGateway: GraphQLNullable<GraphQLEnum<GatewayEnum>> {
      get { __data["preferredGateway"] }
      set { __data["preferredGateway"] = newValue }
    }

    /// Whether to save card details with Kronor, is only useful when you want to set it to false to disable the option to save. Otherwise, the merchant config is what determines whether to save the card details to receive a token. Card details are only saved when the customer has given their consent to store them.
    public var saveCardDetails: GraphQLNullable<Bool> {
      get { __data["saveCardDetails"] }
      set { __data["saveCardDetails"] = newValue }
    }
  }

}