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

    // Твои сервисы
    private let iapService: IAPServiceProtocol
    private let analytics: AnalyticsServiceProtocol
    private let notification: NotificationServiceProtocol

    public init(iapService: IAPServiceProtocol,
                analytics: AnalyticsServiceProtocol,
                notification: NotificationServiceProtocol) {
        self.iapService = iapService
        self.analytics = analytics
        self.notification = notification
    }

    public func toggleDarkMode() {
        isDarkMode.toggle()
        analytics.logEvent(name: "DarkModeToggled", parameters: ["enabled": isDarkMode])
        objectWillChange.send()
    }

    public func toggleNotifications() {
        notificationsEnabled.toggle()
        analytics.logEvent(name: "NotificationsToggled", parameters: ["enabled": notificationsEnabled])
        objectWillChange.send()
    }

    public func purchasePremium() {
        // твоя логика покупки
        objectWillChange.send()
    }

    public func clearError() {
        errorMessage = nil
        objectWillChange.send()
    }
}
