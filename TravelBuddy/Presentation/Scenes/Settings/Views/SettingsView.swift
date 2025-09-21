//
//  SettingsView.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/23/25.
//

import SwiftUI

public struct SettingsView<VM: SettingsViewModelProtocol>: View {
  @ObservedObject var vm: VM

  public init(vm: VM) { self.vm = vm }

  public var body: some View {
    NavigationView {
      Form {
          Toggle("Dark Mode", isOn: Binding(
            get:  { vm.isDarkMode },
            set:  { vm.setDarkMode($0) }
          ))

          Toggle("Notifications", isOn: Binding(
            get:  { vm.notificationsEnabled },
            set:  { vm.setNotifications($0) }
          ))

        Button(action: { vm.purchasePremium() }) {
          Text(vm.premiumUnlocked ? "Premium Unlocked" : "Unlock Premium")
        }
        .disabled(vm.premiumUnlocked)
      }
      .navigationTitle("Settings")
      .alert(item: Binding(
        get: { vm.errorMessage.map { AlertError(message: $0) } },
        set: { _ in vm.clearError() }
      )) { alertError in
        Alert(title: Text("Error"), message: Text(alertError.message))
      }
    }
  }
}

private struct AlertError: Identifiable {
  let id = UUID()
  let message: String
}
