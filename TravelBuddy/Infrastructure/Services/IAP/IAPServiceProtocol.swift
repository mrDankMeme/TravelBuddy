//
//  IAPServiceProtocol.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/28/25.
//



import StoreKit
import Combine

public protocol IAPServiceProtocol {
  /// Асинхронно загружает информацию о продуктах по идентификаторам
  func fetchProducts() -> AnyPublisher<[Product], Error>
  /// Запускает покупку и возвращает верифицированную транзакцию или ошибку
  func purchase(_ product: Product) -> AnyPublisher<Transaction, Error>
}