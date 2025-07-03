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
        window.makeKeyAndVisible()
        
        if UserDefaults.standard.hasCompletedOnboarding {
            showMainInterface()
            return
        }
        let onboardingVM: AnyOnboardingViewModel = container.resolve(AnyOnboardingViewModel.self)
        let onboardingView = OnboardingView(vm: onboardingVM)
        let onboardingHost = UIHostingController(rootView: onboardingView)
        
        window.rootViewController = onboardingHost
        window.makeKeyAndVisible()
        
       
        onboardingVM.$hasCompletedOnboarding
          .filter { $0 }         // только когда станет true
          .first()               // один раз
          .receive(on: DispatchQueue.main)
          .sink { [weak self] _ in
            self?.showMainInterface()
          }
          .store(in: &cancellables)
    }
    
    // MARK: — Build and display the main TabBar
    private func showMainInterface() {
        // POIList Tab (UIKit)
        let poiListVM: AnyPOIListViewModel = container.resolve(AnyPOIListViewModel.self)
          let poiListView = POIListView(viewModel: poiListVM)
          let poiListHost = UIHostingController(rootView: poiListView)
          poiListHost.tabBarItem = UITabBarItem(
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
        tabBar.viewControllers = [poiListHost, settingsHost]
        
        // Replace rootViewController
        window.rootViewController = tabBar
       
    }
    
    
}
