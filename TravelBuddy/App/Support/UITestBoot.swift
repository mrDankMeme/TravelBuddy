//
//  UITestBoot.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 10/7/25.
//


import Foundation

enum UITestBoot {
    static func resetStateIfNeeded() {
        guard AppFlags.isUITesting else { return }
        let defaults = UserDefaults.standard
        defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        defaults.synchronize()
    }
}
