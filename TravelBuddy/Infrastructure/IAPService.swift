//
//  IAPService.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/20/25.
//



import StoreKit
import Combine

public protocol IAPServiceProtocol {
  /// Асинхронно загружает информацию о продуктах по идентификаторам
  func fetchProducts() -> AnyPublisher<[Product], Error>
  /// Запускает покупку и возвращает верифицированную транзакцию или ошибку
  func purchase(_ product: Product) -> AnyPublisher<Transaction, Error>
}

public final class IAPService: IAPServiceProtocol {
  public init() {}

  // MARK: — Загрузка продуктов
  public func fetchProducts() -> AnyPublisher<[Product], Error> {
    Deferred {
      Future { promise in
        Task {
          do {
            let ids: Set<String> = ["com.travelbuddy.premium"]
            let products = try await Product.products(for: ids)
            promise(.success(products))
          } catch {
            promise(.failure(error))
          }
        }
      }
    }
    .eraseToAnyPublisher()
  }

  // MARK: — Покупка продукта
  public func purchase(_ product: Product) -> AnyPublisher<Transaction, Error> {
    Deferred {
      Future { promise in
        Task {
          do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
              // Проверяем подпись транзакции
              switch verification {
              case .verified(let transaction):
                promise(.success(transaction))
              case .unverified(_, let verificationError):
                promise(.failure(verificationError))
              }
            case .userCancelled:
              // Пользователь отменил покупку
              let err = NSError(
                domain: SKErrorDomain,
                code: SKError.paymentCancelled.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "Purchase cancelled"]
              )
              promise(.failure(err))
            case .pending:
              // Покупка ещё в процессе
              let err = NSError(
                domain: SKErrorDomain,
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Purchase pending"]
              )
              promise(.failure(err))
            @unknown default:
              // На случай новых кейсов в будущем
              let err = NSError(
                domain: SKErrorDomain,
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Unknown purchase result"]
              )
              promise(.failure(err))
            }
          } catch {
            // Ошибка самого await product.purchase()
            promise(.failure(error))
          }
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
