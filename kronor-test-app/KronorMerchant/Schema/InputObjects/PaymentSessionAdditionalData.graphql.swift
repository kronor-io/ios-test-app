// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension KronorMerchant {
  /// Arguments for adding additional data to a payment.
  nonisolated struct PaymentSessionAdditionalData: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      customerReference: GraphQLNullable<String> = nil,
      email: String,
      ip: String,
      language: GraphQLEnum<Language>,
      name: String,
      orderLines: GraphQLNullable<[PurchaseOrderLineInput]> = nil,
      phoneNumber: GraphQLNullable<String> = nil,
      shippingAddress: GraphQLNullable<AddressInput> = nil
    ) {
      __data = InputDict([
        "customerReference": customerReference,
        "email": email,
        "ip": ip,
        "language": language,
        "name": name,
        "orderLines": orderLines,
        "phoneNumber": phoneNumber,
        "shippingAddress": shippingAddress
      ])
    }

    /// Unique reference for your customer. When using card-on-file feature, customerReference must be sent.
    public var customerReference: GraphQLNullable<String> {
      get { __data["customerReference"] }
      set { __data["customerReference"] = newValue }
    }

    /// The E-mail address of the customer.
    public var email: String {
      get { __data["email"] }
      set { __data["email"] = newValue }
    }

    /// IP address of the customer attempting the payment.
    public var ip: String {
      get { __data["ip"] }
      set { __data["ip"] = newValue }
    }

    /// Language in which the payment is being handled
    /// Only languages in two-letter `ISO-639-1` format are recognized.
    /// Example: `SV`, `DA`, `NO`, `IS`, `EN`.
    public var language: GraphQLEnum<Language> {
      get { __data["language"] }
      set { __data["language"] = newValue }
    }

    /// The name of the customer that the payment is associated with.
    ///
    /// Max length: 100.
    public var name: String {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }

    /// A list with all purchase items in this order.
    public var orderLines: GraphQLNullable<[PurchaseOrderLineInput]> {
      get { __data["orderLines"] }
      set { __data["orderLines"] = newValue }
    }

    /// Phone number
    /// Max length: 100.
    public var phoneNumber: GraphQLNullable<String> {
      get { __data["phoneNumber"] }
      set { __data["phoneNumber"] = newValue }
    }

    /// Shipping Address for the order.
    public var shippingAddress: GraphQLNullable<AddressInput> {
      get { __data["shippingAddress"] }
      set { __data["shippingAddress"] = newValue }
    }
  }

}