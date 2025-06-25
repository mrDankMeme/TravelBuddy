//
//  AppCoordinator.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/23/25.
//

import UIKit
import SwiftUI

protocol Coordinator {
    func start()
}

final class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let container: DIContainer

    init(window: UIWindow, container: DIContainer = .shared) {
        self.window = window
        self.container = container
    }

    func start() {
        // MARK: — POI Tab (UIKit)
        let poiVC = container.resolve(POIListViewController.self)
        let poiNav = UINavigationController(rootViewController: poiVC)
        poiNav.tabBarItem = UITabBarItem(
            title: "Places",
            image: UIImage(systemName: "map"),
            tag: 0
        )

        // MARK: — Settings Tab (SwiftUI)
        let settingsVM = container.resolve(AnySettingsViewModel.self)
        let settingsView = SettingsView(vm: settingsVM)
        let settingsHost = UIHostingController(rootView: settingsView)
        settingsHost.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            tag: 1
        )

        // MARK: — TabBar Setup
        let tabBar = UITabBarController()
        tabBar.viewControllers = [poiNav, settingsHost]

        // MARK: — Window Setup
        window.rootViewController = tabBar
        window.makeKeyAndVisible()
    }
}
