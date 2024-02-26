// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol KronorMerchant_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == KronorMerchant.SchemaMetadata {}

public protocol KronorMerchant_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == KronorMerchant.SchemaMetadata {}

public protocol KronorMerchant_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == KronorMerchant.SchemaMetadata {}

public protocol KronorMerchant_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == KronorMerchant.SchemaMetadata {}

public extension KronorMerchant {
  typealias ID = String

  typealias SelectionSet = KronorMerchant_SelectionSet

  typealias InlineFragment = KronorMerchant_InlineFragment

  typealias MutableSelectionSet = KronorMerchant_MutableSelectionSet

  typealias MutableInlineFragment = KronorMerchant_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    public static func objectType(forTypename typename: String) -> Object? {
      switch typename {
      case "mutation_root": return KronorMerchant.Objects.Mutation_root
      case "PaymentSessionResult": return KronorMerchant.Objects.PaymentSessionResult
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}