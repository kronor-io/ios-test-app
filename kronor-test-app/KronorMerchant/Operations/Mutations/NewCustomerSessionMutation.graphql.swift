// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension KronorMerchant {
  nonisolated struct NewCustomerSessionMutation: GraphQLMutation {
    public static let operationName: String = "NewCustomerSession"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation NewCustomerSession($sessionInfo: CustomerSessionInput!) { newCustomerSession(sessionInfo: $sessionInfo) { __typename token } }"#
      ))

    public var sessionInfo: CustomerSessionInput

    public init(sessionInfo: CustomerSessionInput) {
      self.sessionInfo = sessionInfo
    }

    @_spi(Unsafe) public var __variables: Variables? { ["sessionInfo": sessionInfo] }

    nonisolated public struct Data: KronorMerchant.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorMerchant.Objects.Mutation_root }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("newCustomerSession", NewCustomerSession.self, arguments: ["sessionInfo": .variable("sessionInfo")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        NewCustomerSessionMutation.Data.self
      ] }

      /// Create a new customer session to allow the customer to edit, save, and delete their saved credit cards
      public var newCustomerSession: NewCustomerSession { __data["newCustomerSession"] }

      /// NewCustomerSession
      ///
      /// Parent Type: `CustomerSessionResult`
      nonisolated public struct NewCustomerSession: KronorMerchant.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorMerchant.Objects.CustomerSessionResult }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("token", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          NewCustomerSessionMutation.Data.NewCustomerSession.self
        ] }

        /// Once a customer session is initialized, you can pass this token to the saved cards sdk
        public var token: String { __data["token"] }
      }
    }
  }

}