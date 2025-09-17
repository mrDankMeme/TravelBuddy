//
//  SettingsViewModel.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/20/25.
//

import Combine
import StoreKit
import SwiftUI

public protocol SettingsViewModelProtocol: ObservableObject {
    var objectWillChange: ObservableObjectPublisher { get }
    
    var isDarkMode: Bool { get }
    var notificationsEnabled: Bool { get }
    var premiumUnlocked: Bool { get }
    var errorMessage: String? { get }

    func toggleDarkMode()
    func toggleNotifications()
    func purchasePremium()
    func clearError()
}


public final class SettingsViewModel: SettingsViewModelProtocol {
  public let objectWillChange = ObservableObjectPublisher()

  @Published public private(set) var isDarkMode = false
  @Published public private(set) var notificationsEnabled = false
  @Published public private(set) var premiumUnlocked = false
  @Published public private(set) var errorMessage: String?

  private let iapService: IAPServiceProtocol
  private let analytics: AnalyticsServiceProtocol
  private let notification: NotificationServiceProtocol
  private var bag = Set<AnyCancellable>()

  public init(iapService: IAPServiceProtocol,
              analytics: AnalyticsServiceProtocol,
              notification: NotificationServiceProtocol) {
    self.iapService = iapService
    self.analytics = analytics
    self.notification = notification

    
    iapService.readCurrentPremiumEntitlement()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] has in self?.premiumUnlocked = has }
      .store(in: &bag)

    
    NotificationCenter.default.publisher(for: .iapEntitlementsChanged)
      .flatMap { [iapService] _ in iapService.readCurrentPremiumEntitlement() }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] has in self?.premiumUnlocked = has }
      .store(in: &bag)
  }

  public func toggleDarkMode() { isDarkMode.toggle() }
  public func toggleNotifications() { notificationsEnabled.toggle() }

  public func purchasePremium() {
    errorMessage = nil

    iapService.fetchProducts()
      .tryMap { products -> Product in
        guard let p = products.first(where: { $0.id == "com.travelbuddy.premium" }) else {
          throw NSError(domain: "IAP", code: -3, userInfo: [NSLocalizedDescriptionKey: "Product not found"])
        }
        return p
      }
      .flatMap { [iapService] product in
        iapService.purchase(product)
      }
      .flatMap { [iapService] _ in
        iapService.readCurrentPremiumEntitlement()
      }
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] comp in
        if case let .failure(err) = comp { self?.errorMessage = err.localizedDescription }
      }, receiveValue: { [weak self] has in
        self?.premiumUnlocked = has
      })
      .store(in: &bag)
  }

  public func clearError() { errorMessage = nil }
}
