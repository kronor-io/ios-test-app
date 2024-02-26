// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension KronorMerchant {
  /// A physical address for a customer.
  struct AddressInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      careOf: GraphQLNullable<String> = nil,
      city: String,
      country: GraphQLEnum<Country>,
      email: String,
      firstName: String,
      lastName: String,
      phoneNumber: String,
      postalCode: String,
      region: GraphQLNullable<String> = nil,
      streetAddress: String,
      streetAddress2: GraphQLNullable<String> = nil,
      streetName: GraphQLNullable<String> = nil,
      streetNumber: GraphQLNullable<String> = nil,
      title: GraphQLNullable<GraphQLEnum<CustomerTitle>> = nil
    ) {
      __data = InputDict([
        "careOf": careOf,
        "city": city,
        "country": country,
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
        "postalCode": postalCode,
        "region": region,
        "streetAddress": streetAddress,
        "streetAddress2": streetAddress2,
        "streetName": streetName,
        "streetNumber": streetNumber,
        "title": title
      ])
    }

    /// Named intermediary.
    /// Max length: 100.
    public var careOf: GraphQLNullable<String> {
      get { __data["careOf"] }
      set { __data["careOf"] = newValue }
    }

    /// City.
    /// Max length: 100.
    public var city: String {
      get { __data["city"] }
      set { __data["city"] = newValue }
    }

    /// Country.
    /// Example: `SE`, `DK`, `NO`, `IS`, `FI`
    public var country: GraphQLEnum<Country> {
      get { __data["country"] }
      set { __data["country"] = newValue }
    }

    /// E-mail address.
    public var email: String {
      get { __data["email"] }
      set { __data["email"] = newValue }
    }

    /// First name or Given Name.
    /// Max length: 100.
    public var firstName: String {
      get { __data["firstName"] }
      set { __data["firstName"] = newValue }
    }

    /// Last name or Family Name.
    /// Max length: 100.
    public var lastName: String {
      get { __data["lastName"] }
      set { __data["lastName"] = newValue }
    }

    /// Phone number
    /// Max length: 100.
    public var phoneNumber: String {
      get { __data["phoneNumber"] }
      set { __data["phoneNumber"] = newValue }
    }

    /// Postal Code.
    public var postalCode: String {
      get { __data["postalCode"] }
      set { __data["postalCode"] = newValue }
    }

    /// State or Region.
    /// Max length: 100.
    public var region: GraphQLNullable<String> {
      get { __data["region"] }
      set { __data["region"] = newValue }
    }

    /// Street address, first line.
    /// This should contain any free text as given by the customer
    ///
    /// Max length: 10000.
    public var streetAddress: String {
      get { __data["streetAddress"] }
      set { __data["streetAddress"] = newValue }
    }

    /// Street address, second line.
    /// This should contain any free text as given by the customer
    ///
    /// Max length: 10000.
    public var streetAddress2: GraphQLNullable<String> {
      get { __data["streetAddress2"] }
      set { __data["streetAddress2"] = newValue }
    }

    /// Street name. Do not combine with streetAddress.
    /// Should only be used if this field has been validated by the merchant
    /// and known to be correct.
    ///
    /// Max length: 10000.
    public var streetName: GraphQLNullable<String> {
      get { __data["streetName"] }
      set { __data["streetName"] = newValue }
    }

    /// Street number. Do not combine with streetAddress.
    /// Should only be used if this field has been validated by the merchant
    /// and known to be correct.
    ///
    /// Max length: 10000.
    public var streetNumber: GraphQLNullable<String> {
      get { __data["streetNumber"] }
      set { __data["streetNumber"] = newValue }
    }

    /// Title used for addressing the customer.
    /// Max length: 100.
    public var title: GraphQLNullable<GraphQLEnum<CustomerTitle>> {
      get { __data["title"] }
      set { __data["title"] = newValue }
    }
  }

}