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

    let objectWillChange = ObservableObjectPublisher()

    @Published private(set) var isDarkMode: Bool = false
    @Published private(set) var notificationsEnabled: Bool = false
    @Published private(set) var premiumUnlocked: Bool = false
    @Published private(set) var errorMessage: String?

    init(_ wrapped: any SettingsViewModelProtocol) {
        self.wrapped = wrapped

        // Теперь здесь гарантированно совпадают типы
        wrapped.objectWillChange
            .sink { [weak self] _ in
                self?.syncProperties()
                self?.objectWillChange.send()
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

    func toggleDarkMode() { wrapped.toggleDarkMode() }
    func toggleNotifications() { wrapped.toggleNotifications() }
    func purchasePremium() { wrapped.purchasePremium() }
    func clearError() { wrapped.clearError() }
}
