//
//  AppCoordinator.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/26/25.
//

import UIKit
import SwiftUI
import Combine

protocol Coordinator {
    func start()
}

final class AppCoordinator: Coordinator {
    // MARK: — Dependencies
    private let window: UIWindow
    private let container: DIContainer
    
    // MARK: — State
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: — Init
    init(window: UIWindow, container: DIContainer = .shared) {
        self.window = window
        self.container = container
    }
    
    // MARK: — Start the app flow
    func start() {
         
        let onboardingVM: AnyOnboardingViewModel = container.resolve(AnyOnboardingViewModel.self)
        let onboardingView = OnboardingView(vm: onboardingVM)
        let onboardingHost = UIHostingController(rootView: onboardingView)
        
        window.rootViewController = onboardingHost
        window.makeKeyAndVisible()
        
       
        onboardingVM.objectWillChange
            .sink { [weak self] _ in
                guard onboardingVM.hasCompletedOnboarding else { return }
                self?.showMainInterface()
            }
            .store(in: &cancellables)
    }
    
    // MARK: — Build and display the main TabBar
    private func showMainInterface() {
        // POIList Tab (UIKit)
        let poiVC = container.resolve(POIListViewController.self)
        let poiNav = UINavigationController(rootViewController: poiVC)
        poiNav.tabBarItem = UITabBarItem(
            title: "Places",
            image: UIImage(systemName: "map"),
            tag: 0
        )
        
        // Settings Tab (SwiftUI)
        let settingsVM: AnySettingsViewModel = container.resolve(AnySettingsViewModel.self)
        let settingsView = SettingsView(vm: settingsVM)
        let settingsHost = UIHostingController(rootView: settingsView)
        settingsHost.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            tag: 1
        )
        
        // Assemble Tab Bar
        let tabBar = UITabBarController()
        tabBar.viewControllers = [poiNav, settingsHost]
        
        // Replace rootViewController
        window.rootViewController = tabBar
    }
}
