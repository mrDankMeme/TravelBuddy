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

@MainActor
final class AppCoordinator: Coordinator {
    // MARK: — Dependencies
    private let window: UIWindow
    private let container: DIContainer

    // MARK: — UI State
    private let tabBar = UITabBarController()
    private var cancellables = Set<AnyCancellable>()

    // MARK: — Init
    init(window: UIWindow, container: DIContainer = .shared) {
        self.window = window
        self.container = container
    }

    // MARK: — Start
    func start() {
        window.makeKeyAndVisible()

        if UserDefaults.standard.hasCompletedOnboarding {
            showMainInterface()
        } else {
            showOnboarding()
        }
    }

    // MARK: — Onboarding Flow
    private func showOnboarding() {
        let onboardingVM: AnyOnboardingViewModel = container.resolve(AnyOnboardingViewModel.self)
        let onboardingHost = UIHostingController(rootView: OnboardingView(vm: onboardingVM))
        window.rootViewController = onboardingHost

        onboardingVM.$hasCompletedOnboarding
            .filter { $0 }
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.showMainInterface() }
            .store(in: &cancellables)
    }

    // MARK: — Main Interface
    private func showMainInterface() {
        // — POIList Tab
        let poiListVM     = container.resolve(AnyPOIListViewModel.self)
        let poiListRouter = container.resolve(POIListRouter.self)
        let poiListCoord  = POIListCoordinator(viewModel: poiListVM, router: poiListRouter)
        let poiListHost   = UIHostingController(rootView: poiListCoord.rootView())
        poiListHost.tabBarItem = UITabBarItem(
            title: "Places",
            image: UIImage(systemName: "map"),
            tag: 0
        )

        // — Map Tab
        let mapVM     = container.resolve(AnyPOIMapViewModel.self)
        let mapRouter = container.resolve(MapRouter.self)
        let mapCoord  = MapCoordinator(vm: mapVM, router: mapRouter)

        let mapHost = UIHostingController(rootView: mapCoord.rootView())
        mapHost.tabBarItem = UITabBarItem(title: "Map",
                                          image: UIImage(systemName: "map.fill"),
                                          tag: 1)


        // — Settings Tab
        let settingsVM = container.resolve(AnySettingsViewModel.self)
        let settingsHost = UIHostingController(rootView: SettingsView(vm: settingsVM))
        settingsHost.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            tag: 2
        )

        // Собираем TabBar
        tabBar.viewControllers = [
            UINavigationController(rootViewController: poiListHost),
            UINavigationController(rootViewController: mapHost),
            UINavigationController(rootViewController: settingsHost)
        ]
        window.rootViewController = tabBar

        // Подключаем детализацию из карты
        setupDetailNavigation()
    }

    // MARK: — Detail Navigation
    private func setupDetailNavigation() {
        NotificationCenter.default.publisher(for: .openPOIDetail)
            .compactMap { $0.object as? POI }
            .sink { [weak self] poi in
                guard
                    let self = self,
                    let nav = self.tabBar.selectedViewController as? UINavigationController
                else { return }

                // Создаем через DI, чтобы не пропустить MainActor.assumeIsolated
                let detailCoordinator = self.container.resolve(
                    POIDetailCoordinator.self,
                    argument: poi
                )
                let detailHost = UIHostingController(rootView: detailCoordinator.rootView())
                nav.pushViewController(detailHost, animated: true)
            }
            .store(in: &cancellables)
    }
}
