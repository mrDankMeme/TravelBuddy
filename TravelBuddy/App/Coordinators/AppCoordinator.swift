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
import CoreLocation

protocol Coordinator {
    func start()
}

@MainActor
final class AppCoordinator: Coordinator {
    // MARK: - Dependencies
    private let window: UIWindow
    private let container: DIContainer

    // IAP
    private let iapObserver: IAPObserver
    private let iapService: IAPServiceProtocol

    // MARK: - UI State
    private let tabBar = UITabBarController()
    private var cancellables = Set<AnyCancellable>()

    // Навигация/роутеры, доступные из разных обработчиков
    private var appRouter: AppRouter!
    private var mapRouter: MapRouter!      // общий экземпляр для вкладки "Map"

    // MARK: - Init
    init(window: UIWindow, container: DIContainer? = nil) {
        self.window = window
        self.container = container ?? DIContainer.shared

        guard
            let observer = self.container.resolver.resolve(IAPObserver.self),
            let iapSvc   = self.container.resolver.resolve(IAPServiceProtocol.self)
        else {
            preconditionFailure("Swinject: IAPObserver/IAPServiceProtocol не зарегистрированы")
        }
        self.iapObserver = observer
        self.iapService  = iapSvc
    }

    // MARK: - Start
    func start() {
        window.makeKeyAndVisible()

        if UserDefaults.standard.hasCompletedOnboarding {
            showMainInterface()
        } else {
            showOnboarding()
        }
    }

    // MARK: - Onboarding
    private func showOnboarding() {
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

    // MARK: - Main UI
    private func showMainInterface() {
        // AppRouter — один на все табы
        guard let appRouter = container.resolver.resolve(AppRouter.self) else {
            preconditionFailure("Swinject: AppRouter не зарегистрирован")
        }
        self.appRouter = appRouter

        // --- Places tab
        guard
            let poiListVM     = container.resolver.resolve(AnyPOIListViewModel.self),
            let poiListRouter = container.resolver.resolve(POIListRouter.self)
        else {
            preconditionFailure("Swinject: нет регистрации AnyPOIListViewModel или POIListRouter")
        }
        let poiListCoord = POIListCoordinator(viewModel: poiListVM, router: poiListRouter)
        let placesVC = UIHostingController(
            rootView: poiListCoord.rootView().environmentObject(appRouter)
        )
        placesVC.tabBarItem = UITabBarItem(title: "Places", image: UIImage(systemName: "map"), tag: 0)

        // --- Map tab
        guard
            let mapVM     = container.resolver.resolve(AnyPOIMapViewModel.self),
            let mapRouter = container.resolver.resolve(MapRouter.self)
        else {
            preconditionFailure("Swinject: нет регистрации AnyPOIMapViewModel или MapRouter")
        }
        self.mapRouter = mapRouter // <— сохраняем ссылку для диплинков/роутинга
        let mapCoord = MapCoordinator(vm: mapVM, router: mapRouter)
        let mapVC = UIHostingController(
            rootView: mapCoord.rootView().environmentObject(appRouter)
        )
        mapVC.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "map.fill"), tag: 1)

        // --- Settings tab
        guard let settingsVM = container.resolver.resolve(AnySettingsViewModel.self) else {
            preconditionFailure("Swinject: AnySettingsViewModel не зарегистрирован")
        }
        let settingsVC = UIHostingController(
            rootView: SettingsView(vm: settingsVM).environmentObject(appRouter)
        )
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 2)

        // --- Assemble
        tabBar.viewControllers = [placesVC, mapVC, settingsVC]
        window.rootViewController = tabBar

        // --- Bindings
        bindAppRouter(appRouter)
        bindDeepLinks()

        // --- IAP
        iapObserver.start()
        iapService.readCurrentPremiumEntitlement()
            .receive(on: DispatchQueue.main)
            .sink { _ in }
            .store(in: &cancellables)
    }

    // MARK: - Bind AppRouter
    private func bindAppRouter(_ appRouter: AppRouter) {
        appRouter.events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                self?.handle(route)
            }
            .store(in: &cancellables)
    }

    // MARK: - Bind Deep Links
    private func bindDeepLinks() {
        guard let deeplinkService = container.resolver.resolve(DeepLinkHandling.self) else { return }

        // Успех — маршрутизируем в карту/табы
        deeplinkService
            .events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] link in
                self?.handleDeepLink(link)
            }
            .store(in: &cancellables)

        // Ошибки парсинга/валидации диплинков — показываем глобальный алерт
        deeplinkService
            .errors
            .receive(on: DispatchQueue.main)
            .sink { [weak self] err in
                self?.presentDeepLinkError(err)
            }
            .store(in: &cancellables)
    }

    // MARK: - Show errors (GLOBAL)
    /// Глобальные ошибки диплинков (scheme/host/coords) — вне контекста Map-сцены.
    private func presentDeepLinkError(_ error: DeepLinkError) {
        let message: String
        switch error {
        case .unsupportedScheme:
            message = L10n.deeplinkUnsupportedScheme
        case .unknownHost:
            message = L10n.deeplinkUnknownHost
        case .invalidCoordinates:
            message = L10n.deeplinkInvalidCoords
        }

        tabBar.presentAlert(
            title: L10n.alertErrorTitle,
            message: message,
            okTitle: L10n.alertOk
        )
    }

    // MARK: - Handle AppRoute (из списков/настроек и т.п.)
    private func handle(_ route: AppRoute) {
        switch route {
        case .openPOIDetail:
            tabBar.selectedIndex = 0

        case .openMapWithPOI(let id):
            tabBar.selectedIndex = 1
            mapRouter?.focusPOI(id)

        case .openSettings:
            tabBar.selectedIndex = 2
        }
    }

    // MARK: - Handle Deep Link (SUCCESS)
    private func handleDeepLink(_ deeplink: DeepLink) {
        switch deeplink {
        case .mapCenter(let coord):
            tabBar.selectedIndex = 1
            mapRouter?.center(on: coord)

        case .poi(let id):
            tabBar.selectedIndex = 1
            // если такого POI в итоге нет — MapContainer сам покажет локализованный алерт
            // через router.showError(.poiNotFound(id)) по таймауту
            mapRouter?.focusPOI(id)
        }
    }
}
