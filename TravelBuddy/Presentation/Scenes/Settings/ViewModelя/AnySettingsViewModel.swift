//
//  AnySettingsViewModel.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/24/25.


import Combine
import StoreKit
import SwiftUI

final class AnySettingsViewModel: ObservableObject, SettingsViewModelProtocol {
    private let wrapped: any SettingsViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    let objectWillChange = ObservableObjectPublisher()

    @Published private(set) var isDarkMode: Bool = false
    @Published private(set) var notificationsEnabled: Bool = false
    @Published private(set) var premiumUnlocked: Bool = false
    @Published private(set) var errorMessage: String?

    init(_ wrapped: any SettingsViewModelProtocol) {
        self.wrapped = wrapped

        // Важно: objectWillChange у wrapped — это willSet.
        // Синхронизируемся на следующий runloop-так, чтобы читать уже обновлённые значения.
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

    private func syncProperties() {
        isDarkMode = wrapped.isDarkMode
        notificationsEnabled = wrapped.notificationsEnabled
        premiumUnlocked = wrapped.premiumUnlocked
        errorMessage = wrapped.errorMessage
    }

    func setDarkMode(_ isOn: Bool) {
        if isDarkMode != isOn {
            isDarkMode = isOn          // мгновенно для SwiftUI
            objectWillChange.send()    // на случай, если где-то нужен немедленный импульс
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
}
