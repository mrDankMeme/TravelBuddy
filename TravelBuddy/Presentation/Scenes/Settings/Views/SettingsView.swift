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
                // MARK: - Appearance
                Section {
                    Toggle(L10n.settingsDarkMode, isOn: Binding(
                        get:  { vm.isDarkMode },
                        set:  { vm.setDarkMode($0) }
                    ))
                    .accessibilityIdentifier("settings.darkmode.toggle")
                }

                // MARK: - Local Notifications (как было)
                Section {
                    Toggle(L10n.settingsNotifications, isOn: Binding(
                        get:  { vm.notificationsEnabled },
                        set:  { vm.setNotifications($0) }
                    ))
                    .accessibilityIdentifier("settings.notifications.toggle")
                }

                // MARK: - APNs / Push (НОВОЕ)
                Section(header: Text("Push Notifications")) {
                    HStack {
                        Text("Permission")
                        Spacer()
                        Text(vm.pushPermissionText).foregroundStyle(.secondary)
                    }

                    Toggle("Show banner in Foreground", isOn: Binding(
                        get: { vm.presentInForeground },
                        set: { vm.setPresentInForeground($0) }
                    ))

                    if let token = vm.apnsToken, !token.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("APNs Device Token")
                                .font(.subheadline.weight(.semibold))
                            Text(token)
                                .font(.footnote)
                                .textSelection(.enabled)
                                .lineLimit(3)
                        }
                        .padding(.vertical, 4)
                    } else {
                        Text("APNs token is not available yet.")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    }

                    Button("Request Permission") {
                        Task { await vm.requestPushPermission() }
                    }
                    Button("Register for Remote Notifications") {
                        vm.registerForRemoteNotifications()
                    }
                    Button("Schedule Local Test") {
                        Task { await vm.scheduleLocalPushTest() }
                    }
                }

                // MARK: - Premium (как было)
                Section {
                    Button(action: { vm.purchasePremium() }) {
                        Text(vm.premiumUnlocked
                             ? L10n.settingsPremiumUnlocked
                             : L10n.settingsPremiumUnlock)
                    }
                    .disabled(vm.premiumUnlocked)
                    .accessibilityIdentifier("settings.premium.button")
                }
            }
            .navigationTitle(L10n.navSettingsTitle)
            .task { await vm.refreshPush() } // подтянем статус/токен при открытии
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
