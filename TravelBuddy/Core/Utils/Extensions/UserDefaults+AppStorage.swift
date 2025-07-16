//
//  UserDefaults+AppStorage.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/26/25.
//

import Foundation

extension UserDefaults {
  // MARK: — Ключи
  private enum Keys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    // в будущем сюда можно добавлять другие ключи
  }

  // MARK: — Свойства
  var hasCompletedOnboarding: Bool {
    get { bool(forKey: Keys.hasCompletedOnboarding) }
    set { set(newValue, forKey: Keys.hasCompletedOnboarding) }
  }
}
