//
//  AnySettingsViewModel.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/24/25.
//

import Combine
import StoreKit
import SwiftUI

final class AnySettingsViewModel: ObservableObject, SettingsViewModelProtocol {
    private let wrapped: any SettingsViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - SettingsViewModelProtocol
    let objectWillChange = ObservableObjectPublisher()

    // Старые поля
    @Published private(set) var isDarkMode: Bool = false
    @Published private(set) var notificationsEnabled: Bool = false
    @Published private(set) var premiumUnlocked: Bool = false
    @Published private(set) var errorMessage: String?

    // Новые поля (Push / APNs)
    @Published private(set) var pushPermissionText: String = "Not Determined"
    @Published private(set) var apnsToken: String?
    @Published private(set) var presentInForeground: Bool = true

    // MARK: - Init
    init(_ wrapped: any SettingsViewModelProtocol) {
        self.wrapped = wrapped

        // Важно: objectWillChange у wrapped — willSet.
        // Синхронизируемся на следующий runloop-такт, чтобы читать уже обновлённые значения.
        wrapped.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.syncProperties()
                    self.objectWillChange.send()
                }
            }
            .store(in: &cancellables)

        syncProperties()
    }

    // MARK: - Private
    private func syncProperties() {
        // Старые
        isDarkMode = wrapped.isDarkMode
        notificationsEnabled = wrapped.notificationsEnabled
        premiumUnlocked = wrapped.premiumUnlocked
        errorMessage = wrapped.errorMessage

        // Новые (Push)
        pushPermissionText = wrapped.pushPermissionText
        apnsToken = wrapped.apnsToken
        presentInForeground = wrapped.presentInForeground
    }

    // MARK: - Settings (старое API)
    func setDarkMode(_ isOn: Bool) {
        if isDarkMode != isOn {
            isDarkMode = isOn          // мгновенно для SwiftUI
            objectWillChange.send()
        }
        wrapped.setDarkMode(isOn)      // источник истины
    }

    func setNotifications(_ isOn: Bool) {
        if notificationsEnabled != isOn {
            notificationsEnabled = isOn
            objectWillChange.send()
        }
        wrapped.setNotifications(isOn)
    }

    func purchasePremium() { wrapped.purchasePremium() }
    func clearError()      { wrapped.clearError() }

    // MARK: - Push / APNs (новое API)
    @MainActor
    func refreshPush() async {
        await wrapped.refreshPush()
        // wrapped дернул свои паблишеры → прилетит через objectWillChange,
        // но синхронизируемся на всякий случай сразу:
        syncProperties()
        objectWillChange.send()
    }

    @MainActor
    func requestPushPermission() async {
        await wrapped.requestPushPermission()
        syncProperties()
        objectWillChange.send()
    }

    @MainActor
    func scheduleLocalPushTest() async {
        await wrapped.scheduleLocalPushTest()
        syncProperties()
        objectWillChange.send()
    }

    func registerForRemoteNotifications() {
        wrapped.registerForRemoteNotifications()
        syncProperties()
        objectWillChange.send()
    }

    func setPresentInForeground(_ isOn: Bool) {
        if presentInForeground != isOn {
            presentInForeground = isOn  // мгновенно в UI
            objectWillChange.send()
        }
        wrapped.setPresentInForeground(isOn)
    }
}
