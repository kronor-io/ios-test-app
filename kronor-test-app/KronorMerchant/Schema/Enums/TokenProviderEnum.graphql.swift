// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) import ApolloAPI

public extension KronorMerchant {
  /// Token providers we support
  nonisolated enum TokenProviderEnum: String, EnumType {
    /// Device tokens returned by Apple Pay
    case applepay = "APPLEPAY"
    /// The token is the actual pan in this scenario where customer just enters his card details.
    case customer = "CUSTOMER"
    /// Device tokens returned by Google Pay
    case googlepay = "GOOGLEPAY"
    /// Kronor token service
    case kronor = "KRONOR"
    /// Network tokenization service provided by Mastercard.
    case mastercard = "MASTERCARD"
  }

}