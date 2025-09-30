//
//  SettingsView.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/23/25.
//

import SwiftUI

public struct SettingsView<VM: SettingsViewModelProtocol>: View {
    @ObservedObject private var vm: VM

    public init(vm: VM) { self.vm = vm }

    public var body: some View {
        NavigationView {
            Form {
                // Dark Mode
                Toggle(L10n.settingsDarkMode, isOn: Binding(
                    get:  { vm.isDarkMode },
                    set:  { vm.setDarkMode($0) }
                ))
                .accessibilityIdentifier("settings.darkmode.toggle")

                // Notifications
                Toggle(L10n.settingsNotifications, isOn: Binding(
                    get:  { vm.notificationsEnabled },
                    set:  { vm.setNotifications($0) }
                ))
                .accessibilityIdentifier("settings.notifications.toggle")

                // Premium
                Button(action: { vm.purchasePremium() }) {
                    Text(vm.premiumUnlocked
                         ? L10n.settingsPremiumUnlocked
                         : L10n.settingsPremiumUnlock)
                }
                .disabled(vm.premiumUnlocked)
                .accessibilityIdentifier("settings.premium.button")
            }
            .navigationTitle(L10n.navSettingsTitle)
            .alert(item: Binding(
                get: { vm.errorMessage.map { AlertError(message: $0) } },
                set: { _ in vm.clearError() }
            )) { alertError in
                Alert(
                    title: Text(L10n.alertErrorTitle),
                    message: Text(alertError.message),
                    dismissButton: .default(Text(L10n.alertOk))
                )
            }
        }
    }
}

private struct AlertError: Identifiable {
    let id = UUID()
    let message: String
}
