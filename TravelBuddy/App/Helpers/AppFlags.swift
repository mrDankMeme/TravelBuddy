//
//  AppFlags.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 10/04/25.
//

import Foundation

/// Флаги, которые управляют режимом работы приложения (например, UI-тесты, мок-данные и т.п.)
enum AppFlags {
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-uiTesting")
    }

    static var useMockData: Bool {
        ProcessInfo.processInfo.arguments.contains("-uiMockData")
    }
}
