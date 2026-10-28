// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension KronorMerchant {
  /// Arguments for creating a new customer session.
  nonisolated struct CustomerSessionInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      country: GraphQLNullable<GraphQLEnum<Country>> = nil,
      currency: GraphQLNullable<GraphQLEnum<SupportedCurrencyEnum>> = nil,
      customerReference: String,
      email: String,
      expiresAt: String,
      idempotencyKey: String,
      ip: String,
      language: GraphQLEnum<Language>,
      merchantReference: String,
      name: String,
      phoneNumber: GraphQLNullable<String> = nil,
      tokenProvider: GraphQLNullable<GraphQLEnum<TokenProviderEnum>> = nil
    ) {
      __data = InputDict([
        "country": country,
        "currency": currency,
        "customerReference": customerReference,
        "email": email,
        "expiresAt": expiresAt,
        "idempotencyKey": idempotencyKey,
        "ip": ip,
        "language": language,
        "merchantReference": merchantReference,
        "name": name,
        "phoneNumber": phoneNumber,
        "tokenProvider": tokenProvider
      ])
    }

    /// The country where any save card requests will take place.
    /// Defaults to the merchant's default country.
    /// Example: `SE`, `DK`, `NO`, `IS`, `FI`
    public var country: GraphQLNullable<GraphQLEnum<Country>> {
      get { __data["country"] }
      set { __data["country"] = newValue }
    }

    /// When `currency` is not set, it defaults to the merchant's default currency.
    ///
    /// When customer requests to save card, the zero amount auth takes place in this currency
    public var currency: GraphQLNullable<GraphQLEnum<SupportedCurrencyEnum>> {
      get { __data["currency"] }
      set { __data["currency"] = newValue }
    }

    /// Unique reference for your customer, this should be the same reference that is sent in PaymentSessionAdditionalData.customerReference.
    ///
    /// Max length: 64.
    public var customerReference: String {
      get { __data["customerReference"] }
      set { __data["customerReference"] = newValue }
    }

    /// The E-mail address of the customer.
    public var email: String {
      get { __data["email"] }
      set { __data["email"] = newValue }
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

    /// IP address of the customer attempting the payment.
    public var ip: String {
      get { __data["ip"] }
      set { __data["ip"] = newValue }
    }

    /// Language the session should use.
    /// Only languages in two-letter `ISO-639-1` format are recognized.
    /// Example: `SV`, `DA`, `NO`, `IS`, `EN`.
    public var language: GraphQLEnum<Language> {
      get { __data["language"] }
      set { __data["language"] = newValue }
    }

    /// Merchant's internal reference that may help the merchant in identifying this customer session.
    ///
    /// Max length: 64.
    public var merchantReference: String {
      get { __data["merchantReference"] }
      set { __data["merchantReference"] = newValue }
    }

    /// The name of the customer that the payment is associated with.
    ///
    /// Max length: 100.
    public var name: String {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }

    /// Phone number
    /// Max length: 100.
    public var phoneNumber: GraphQLNullable<String> {
      get { __data["phoneNumber"] }
      set { __data["phoneNumber"] = newValue }
    }

    /// The preferred tokenization service to use to save customer cards in this session.
    /// Only "KRONOR" is supported at the moment and as such defaults to it.
    public var tokenProvider: GraphQLNullable<GraphQLEnum<TokenProviderEnum>> {
      get { __data["tokenProvider"] }
      set { __data["tokenProvider"] = newValue }
    }
  }

}