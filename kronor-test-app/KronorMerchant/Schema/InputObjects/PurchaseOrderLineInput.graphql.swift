// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension KronorMerchant {
  /// List of order items which are part of this checkout.
  struct PurchaseOrderLineInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      imageUrl: GraphQLNullable<String> = nil,
      itemUrl: GraphQLNullable<String> = nil,
      name: String,
      pricePerItem: Int,
      quantity: Int,
      reference: GraphQLNullable<String> = nil,
      taxRate: Int,
      totalAmount: Int,
      totalDiscountAmount: GraphQLNullable<Int> = nil,
      totalTaxAmount: Int
    ) {
      __data = InputDict([
        "imageUrl": imageUrl,
        "itemUrl": itemUrl,
        "name": name,
        "pricePerItem": pricePerItem,
        "quantity": quantity,
        "reference": reference,
        "taxRate": taxRate,
        "totalAmount": totalAmount,
        "totalDiscountAmount": totalDiscountAmount,
        "totalTaxAmount": totalTaxAmount
      ])
    }

    /// URL to an image that can be used later in communications between kronor
    /// and the customer.
    ///
    /// Max length: 10000.
    public var imageUrl: GraphQLNullable<String> {
      get { __data["imageUrl"] }
      set { __data["imageUrl"] = newValue }
    }

    /// URL to item in the merchant catalog, that will be used in communications between
    /// kronor and the customer.
    ///
    /// Max length: 10000.
    public var itemUrl: GraphQLNullable<String> {
      get { __data["itemUrl"] }
      set { __data["itemUrl"] = newValue }
    }

    /// The name of the purchased item
    ///
    /// Max length: 100.
    public var name: String {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }

    /// Price per item in this line in minor units. It should include tax, but not any discounts.
    /// Example: `1500,25` SEK should be `150025`.
    /// Example `100` SEK should be `10000`.
    public var pricePerItem: Int {
      get { __data["pricePerItem"] }
      set { __data["pricePerItem"] = newValue }
    }

    /// Number of items ordered by the customer. Needs to be a positive number.
    public var quantity: Int {
      get { __data["quantity"] }
      set { __data["quantity"] = newValue }
    }

    /// Merchant's own internal item number or any other reference that may help the
    /// merchant in identifying this purchase.
    ///
    /// Max length: 64.
    public var reference: GraphQLNullable<String> {
      get { __data["reference"] }
      set { __data["reference"] = newValue }
    }

    /// Tax rate on the items ordered in this line.
    /// Needs to be a non-negative number.
    /// Example: `15%` discount should be represented as `1500`.
    public var taxRate: Int {
      get { __data["taxRate"] }
      set { __data["taxRate"] = newValue }
    }

    /// Total tax amount on all the items in this line in minor units.
    /// Example: 1500,25 SEk should be 150025.
    /// Example 100 SEK should be 10000.
    public var totalAmount: Int {
      get { __data["totalAmount"] }
      set { __data["totalAmount"] = newValue }
    }

    /// Discount applied on all the items in this line in minor units.
    /// This value should include any applicable tax.
    /// Example: `1500,25` SEK should be `150025`.
    /// Example `100` SEK should be `10000`.
    public var totalDiscountAmount: GraphQLNullable<Int> {
      get { __data["totalDiscountAmount"] }
      set { __data["totalDiscountAmount"] = newValue }
    }

    /// Total tax amount on all the items in this line in minor units.
    /// Example: 1500,25 SEk should be 150025.
    ///
    /// Example 100 SEK should be 10000.
    public var totalTaxAmount: Int {
      get { __data["totalTaxAmount"] }
      set { __data["totalTaxAmount"] = newValue }
    }
  }

}