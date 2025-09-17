//
//  AppCoordinator.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/26/25.
//


import UIKit
import SwiftUI
import Combine
import Swinject

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

    init(window: UIWindow, container: DIContainer? = nil) {
        self.window = window
        self.container = container ?? DIContainer.shared
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
        // ⟶ только через resolver
        guard let onboardingVM = container.resolver.resolve(AnyOnboardingViewModel.self) else {
            preconditionFailure("Swinject: AnyOnboardingViewModel не зарегистрирован")
        }

        let onboardingHost = UIHostingController(rootView: OnboardingView(vm: onboardingVM))
        window.rootViewController = onboardingHost

        onboardingVM.$hasCompletedOnboarding
            .filter { $0 }
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.showMainInterface()
            }
            .store(in: &cancellables)
    }

    // MARK: — Main Interface
    private func showMainInterface() {
     
        guard let appRouter = container.resolver.resolve(AppRouter.self) else {
                preconditionFailure("Swinject: AppRouter не зарегистрирован")
        }
        
        // — POIList Tab
        guard
            let poiListVM     = container.resolver.resolve(AnyPOIListViewModel.self),
            let poiListRouter = container.resolver.resolve(POIListRouter.self)
        else {
            preconditionFailure("Swinject: нет регистрации AnyPOIListViewModel или POIListRouter")
        }

        let poiListCoord = POIListCoordinator(viewModel: poiListVM, router: poiListRouter)
        let poiListHost  = UIHostingController(
            rootView: poiListCoord.rootView().environmentObject(appRouter)
        )
        poiListHost.tabBarItem = UITabBarItem(
            title: "Places",
            image: UIImage(systemName: "map"),
            tag: 0
        )

        // — Map Tab
        guard
            let mapVM     = container.resolver.resolve(AnyPOIMapViewModel.self),
            let mapRouter = container.resolver.resolve(MapRouter.self)
        else {
            preconditionFailure("Swinject: нет регистрации AnyPOIMapViewModel или MapRouter")
        }

        let mapCoord = MapCoordinator(vm: mapVM, router: mapRouter)
        let mapHost  = UIHostingController(rootView: mapCoord.rootView().environmentObject(appRouter)
        )
        mapHost.tabBarItem = UITabBarItem(
            title: "Map",
            image: UIImage(systemName: "map.fill"),
            tag: 1
        )

        // — Settings Tab
        guard let settingsVM = container.resolver.resolve(AnySettingsViewModel.self) else {
            preconditionFailure("Swinject: AnySettingsViewModel не зарегистрирован")
        }

        let settingsHost = UIHostingController(
            rootView: SettingsView(vm: settingsVM).environmentObject(appRouter)
        )
        settingsHost.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            tag: 2
        )

        // Собираем TabBar
        tabBar.viewControllers = [
            poiListHost,
            mapHost,
            settingsHost
        ]
        window.rootViewController = tabBar

        bindAppRouter(appRouter)

    }
    // MARK: — AppRouter binding
    private func bindAppRouter(_ appRouter: AppRouter) {
        appRouter.events
            .sink { [weak self] route in
                self?.handle(route)
            }
            .store(in: &cancellables)
    }

    private func handle(_ route: AppRoute) {
//        switch route {
//        case .openPOIDetail(let poi):
//            guard
//                let nav = tabBar.selectedViewController as? UINavigationController,
//                let coord = container.resolver.resolve(POIDetailCoordinator.self, argument: poi)
//            else { return }
//
//            let host = UIHostingController(rootView: coord.rootView())
//            nav.pushViewController(host, animated: true)
//
//        case .openMapWithPOI(_):
//            tabBar.selectedIndex = 1
//
//        case .openSettings:
//            tabBar.selectedIndex = 2
//        }
    }


}
