//
//  ThemeService.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 10/7/25.
//


import Combine
import Foundation

/// Хранит и публикует состояние темы, сохраняет в UserDefaults
final class ThemeService: ThemeServiceProtocol {
    @Published var isDark: Bool {
        didSet { UserDefaults.standard.set(isDark, forKey: Keys.darkMode) }
    }

    var changes: AnyPublisher<Bool, Never> { $isDark.eraseToAnyPublisher() }

    private enum Keys { static let darkMode = "settings.darkMode" }

    init() {
        isDark = UserDefaults.standard.bool(forKey: Keys.darkMode)
    }
}
