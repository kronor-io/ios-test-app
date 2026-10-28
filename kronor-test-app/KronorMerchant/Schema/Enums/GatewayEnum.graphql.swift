// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) import ApolloAPI

public extension KronorMerchant {
  /// Gateways that payments can be processed through
  nonisolated enum GatewayEnum: String, EnumType {
    /// Avarda
    case avarda = "AVARDA"
    /// Enable Banking
    case enableBanking = "ENABLE_BANKING"
    /// Finshark
    case finshark = "FINSHARK"
    /// Kronor
    case kronor = "KRONOR"
    /// Reepay
    case reepay = "REEPAY"
    /// Trustly
    case trustly = "TRUSTLY"
  }

}