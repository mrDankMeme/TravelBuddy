//
//  IAPObserver.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 9/17/25.
//


import StoreKit
import Combine

extension Notification.Name {
  static let iapEntitlementsChanged = Notification.Name("iapEntitlementsChanged")
}

public final class IAPObserver {
  private let iap: IAPServiceProtocol
  private var task: Task<Void, Never>?

  public init(iap: IAPServiceProtocol) { self.iap = iap }

  public func start() {
    guard task == nil else { return }
    task = Task.detached { [weak self] in
      await self?.observeTransactions()
    }
  }

  public func stop() { task?.cancel(); task = nil }
  deinit { stop() }

  private func observeTransactions() async {
    for await update in Transaction.updates {
      do {
        let tx: Transaction = try iap.verify(update)
        // выдаю право пользователю на использование
        await tx.finish()
        // сообщим UI, что энтитлменты могли измениться
        NotificationCenter.default.post(name: .iapEntitlementsChanged, object: nil)
      } catch {
        // опционально: лог/метрики
      }
    }
  }
}
