//
//  Client.swift
//  kronor-test-app
//
//  Created by Jose-JORO on 2023-01-03.
//

import Foundation
import Apollo
import KronorApi

let merchantToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOiAyNTUxNzAzMzU1LjkyNTAwMCwgImlhdCI6IDE2ODc3ODk3NTUuOTI1MDAwLCAidGlkIjogIjJlMDliOWJjLTQ4YWMtNDI5Mi04NzY5LTMzZTAyM2Q1MTk0NyIsICJ0bmFtZSI6IG51bGwsICJ0dHlwZSI6ICJiYWNrZW5kIiwgImh0dHBzOi8vaGFzdXJhLmlvL2p3dC9jbGFpbXMiOiB7IngtaGFzdXJhLW1lcmNoYW50LWlkIjogIjIiLCAieC1oYXN1cmEtZGVmYXVsdC1yb2xlIjogIm1lcmNoYW50LWJhY2tlbmQiLCAieC1oYXN1cmEtYWxsb3dlZC1yb2xlcyI6IFsibWVyY2hhbnQtYmFja2VuZCJdfX0.k4D25fMcWA-6Tlqx6ULMa3T_v7Li4BYilqW49s49qNg"
func makeGraphQLClientForTestMerchant() -> ApolloClient {
    return KronorApi.makeGraphQLClient(env: .sandbox, token: merchantToken)
}

