// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

nonisolated public protocol KronorMerchant_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == KronorMerchant.SchemaMetadata {}

nonisolated public protocol KronorMerchant_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == KronorMerchant.SchemaMetadata {}

nonisolated public protocol KronorMerchant_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == KronorMerchant.SchemaMetadata {}

nonisolated public protocol KronorMerchant_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == KronorMerchant.SchemaMetadata {}

public extension KronorMerchant {
  typealias SelectionSet = KronorMerchant_SelectionSet

  typealias InlineFragment = KronorMerchant_InlineFragment

  typealias MutableSelectionSet = KronorMerchant_MutableSelectionSet

  typealias MutableInlineFragment = KronorMerchant_MutableInlineFragment

  nonisolated enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    public static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    private static let objectTypeMap: [String: ApolloAPI.Object] = [
      "PaymentSessionResult": KronorMerchant.Objects.PaymentSessionResult,
      "mutation_root": KronorMerchant.Objects.Mutation_root
    ]

    @_spi(Execution) public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      objectTypeMap[typename]
    }
  }

  nonisolated enum Objects {}
  nonisolated enum Interfaces {}
  nonisolated enum Unions {}

}