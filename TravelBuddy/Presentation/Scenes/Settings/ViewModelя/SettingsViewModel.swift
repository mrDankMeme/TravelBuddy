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
    
    // БЫЛО
    var isDarkMode: Bool { get }
    var notificationsEnabled: Bool { get }
    var premiumUnlocked: Bool { get }
    var errorMessage: String? { get }
    func setDarkMode(_ isOn: Bool)
    func setNotifications(_ isOn: Bool)
    func purchasePremium()
    func clearError()

    // ► НОВОЕ: APNs/Push
    var pushPermissionText: String { get }
    var apnsToken: String? { get }
    var presentInForeground: Bool { get }
    @MainActor func refreshPush() async
    @MainActor func requestPushPermission() async
    @MainActor func scheduleLocalPushTest() async
    func registerForRemoteNotifications()
    func setPresentInForeground(_ isOn: Bool)
}

@MainActor
public final class SettingsViewModel: SettingsViewModelProtocol {
    public let objectWillChange = ObservableObjectPublisher()
    
    private enum Keys {
        static let darkMode = "settings.darkMode"
        static let notificationsEnabled = "settings.notificationsEnabled"
    }
    
    // MARK: — Public state (старое)
    @Published public private(set) var isDarkMode = UserDefaults.standard.bool(forKey: Keys.darkMode)
    @Published public private(set) var notificationsEnabled = UserDefaults.standard.bool(forKey: Keys.notificationsEnabled)
    @Published public private(set) var premiumUnlocked = false
    @Published public private(set) var errorMessage: String?
    
    // MARK: — Новое: push/APNs
    @Published private var pushPermission: PushPermissionStatus = .notDetermined
    @Published public private(set) var apnsToken: String?
    @Published public private(set) var presentInForeground: Bool = true

    // MARK: — Deps
    private let iapService: IAPServiceProtocol
    private let analytics: AnalyticsServiceProtocol
    private let notification: NotificationServiceProtocol
    private let push: PushServiceProtocol?   // <-- теперь приходит из DI

    private var bag = Set<AnyCancellable>()
    
    public init(iapService: IAPServiceProtocol,
                analytics: AnalyticsServiceProtocol,
                notification: NotificationServiceProtocol,
                push: PushServiceProtocol?) {
        self.iapService = iapService
        self.analytics  = analytics
        self.notification = notification
        self.push = push

        // стартовая синхронизация push-состояния
        self.apnsToken = push?.apnsDeviceTokenHex
        self.presentInForeground = push?.presentInForeground ?? self.presentInForeground
        
        // Premium entitlement (как было)
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
    
    // MARK: — Settings (старое)
    public func setDarkMode(_ isOn: Bool) {
        guard isDarkMode != isOn else { return }
        isDarkMode = isOn
        UserDefaults.standard.set(isOn, forKey: Keys.darkMode)
        analytics.logEvent(name: "settings_dark_mode_changed", parameters: ["value": isOn])
    }
    
    public func setNotifications(_ isOn: Bool) {
        guard notificationsEnabled != isOn else { return }
        notificationsEnabled = isOn
        UserDefaults.standard.set(isOn, forKey: Keys.notificationsEnabled )
        analytics.logEvent(name: "settings_notifications_changed", parameters: ["value": isOn])
        if isOn {
            notification.requestAuthorization().sink { _ in }.store(in: &bag)
        }
    }

    public func purchasePremium() {
        errorMessage = nil
        
        iapService.fetchProducts()
            .tryMap { products -> Product in
                guard let p = products.first else {
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

    // MARK: — Push/APNs
    public var pushPermissionText: String {
        switch pushPermission {
        case .notDetermined: return "Not Determined"
        case .denied:        return "Denied"
        case .authorized:    return "Authorized"
        case .provisional:   return "Provisional"
        case .ephemeral:     return "Ephemeral"
        }
    }

    @MainActor
    public func refreshPush() async {
        guard let push else { return }
        pushPermission      = await push.getPermissionStatus()
        apnsToken           = push.apnsDeviceTokenHex
        presentInForeground = push.presentInForeground
        objectWillChange.send()
    }

    @MainActor
    public func requestPushPermission() async {
        guard let push else { return }
        _ = await push.requestPermission(options: .all)
        await refreshPush()
    }

    public func registerForRemoteNotifications() {
        push?.registerForRemoteNotifications()
        apnsToken = push?.apnsDeviceTokenHex
        objectWillChange.send()
    }

    @MainActor
    public func scheduleLocalPushTest() async {
        guard let push else { return }
        do {
            try await push.scheduleLocal(
                title: "Local notification",
                body: "This is a local test notification.",
                after: 2
            )
        } catch {
            errorMessage = error.localizedDescription
            objectWillChange.send()
        }
    }

    public func setPresentInForeground(_ isOn: Bool) {
        presentInForeground = isOn
        push?.presentInForeground = isOn
        objectWillChange.send()
    }
}
