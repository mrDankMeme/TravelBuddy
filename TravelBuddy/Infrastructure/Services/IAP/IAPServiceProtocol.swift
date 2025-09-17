//
//  IAPServiceProtocol.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/28/25.
//



import StoreKit
import Combine


public protocol IAPServiceProtocol {
  func fetchProducts() -> AnyPublisher<[Product], Error>
  func purchase(_ product: Product) -> AnyPublisher<Transaction, Error>
  func verify<T>(_ result: VerificationResult<T>) throws -> T
  func readCurrentPremiumEntitlement() -> AnyPublisher<Bool, Never>
}
