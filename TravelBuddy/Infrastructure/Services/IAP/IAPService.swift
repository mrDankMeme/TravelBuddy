//
//  IAPService.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/20/25.
//


import StoreKit
import Combine

public final class IAPService: IAPServiceProtocol {
  public init() {}

  public func fetchProducts() -> AnyPublisher<[Product], Error> {
    Deferred {
      Future { promise in
        Task {
          do {
            let ids: Set<String> = ["com.travelbuddy.premium"]
            let products = try await Product.products(for: ids)
            promise(.success(products))
          } catch { promise(.failure(error)) }
        }
      }
    }
    .eraseToAnyPublisher()
  }

  public func purchase(_ product: Product) -> AnyPublisher<Transaction, Error> {
    Deferred {
      Future { promise in
        Task {
          do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
              let tx: Transaction = try self.verify(verification)
              await tx.finish()
              promise(.success(tx))
            case .userCancelled:
              let err = NSError(domain: "IAP", code: NSUserCancelledError,
                                userInfo: [NSLocalizedDescriptionKey: "Purchase cancelled"])
              promise(.failure(err))
            case .pending:
              let err = NSError(domain: "IAP", code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Purchase pending"])
              promise(.failure(err))
            @unknown default:
              let err = NSError(domain: "IAP", code: -2,
                                userInfo: [NSLocalizedDescriptionKey: "Unknown purchase result"])
              promise(.failure(err))
            }
          } catch { promise(.failure(error)) }
        }
      }
    }
    .eraseToAnyPublisher()
  }

  // MARK: - NEW
  public func verify<T>(_ result: VerificationResult<T>) throws -> T {
    switch result {
    case .verified(let safe): return safe
    case .unverified(_, let error): throw error
    }
  }

  public func readCurrentPremiumEntitlement() -> AnyPublisher<Bool, Never> {
    Deferred {
      Future<Bool, Never> { promise in
        Task {
          var hasPremium = false
          for await entitlement in Transaction.currentEntitlements {
            if case .verified(let tx) = entitlement,
               tx.productID == "com.travelbuddy.premium" {
              hasPremium = true
              break
            }
          }
          promise(.success(hasPremium))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
