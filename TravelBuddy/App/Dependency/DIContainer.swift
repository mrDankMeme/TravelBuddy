//
//  DIContainer.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/23/25.
//


// DIContainer.swift
import Foundation
import Swinject
import UIKit
import SwiftUI

@MainActor
public final class DIContainer {
    public static let shared = DIContainer()
    let container = Container() // оставляем internal, чтобы можно было собрать тестовый контейнер

    private init() {
       
        // MARK: — Core Navigation (глобальная шина маршрутов)
        container.register(AppRouter.self) { _ in AppRouter() }
            .inObjectScope(.container)   

        // MARK: — Core
        container.register(HTTPClientProtocol.self) { _ in HTTPClient() }
            .inObjectScope(.container)

        // MARK: — Services
        container.register(AnalyticsServiceProtocol.self) { _ in AnalyticsService() }
            .inObjectScope(.container)
       
        container.register(IAPServiceProtocol.self) { _ in IAPService() }
          .inObjectScope(.container)

        container.register(IAPObserver.self) { r in
          IAPObserver(iap: r.resolve(IAPServiceProtocol.self)!)
        }
       
        .inObjectScope(.container)
        container.register(NotificationServiceProtocol.self) { _ in NotificationService() }
            .inObjectScope(.container)
        

        // MARK: — Scene: Onboarding
        container.register((any OnboardingViewModelProtocol).self) { _ in OnboardingViewModel() }
        container.register(AnyOnboardingViewModel.self) { r in
            AnyOnboardingViewModel(r.resolve((any OnboardingViewModelProtocol).self)!)
        }.inObjectScope(.graph)

        // MARK: — Scene: POIList
        container.register(RemotePOIService.self) { r in
            RemotePOIService(httpClient: r.resolve(HTTPClientProtocol.self)!)
        }
        container.register(LocalPOIService.self) { _ in LocalPOIService() }
        container.register(POICacheProtocol.self) { _ in RealmPOICache() }

        container.register(POIServiceProtocol.self) { r in
            POIRepository(
                remote: r.resolve(RemotePOIService.self)!,
                local:  r.resolve(LocalPOIService.self)!,
                cache:  r.resolve(POICacheProtocol.self)!
            )
        }.inObjectScope(.container) // repo как фасад поверх remote/local/cache — ок в контейнере

        container.register((any POIListViewModelProtocol).self) { r in
            POIListViewModel(repository: r.resolve(POIServiceProtocol.self)!)
        }.inObjectScope(.graph)

        container.register(AnyPOIListViewModel.self) { r in
            AnyPOIListViewModel(r.resolve((any POIListViewModelProtocol).self)!)
        }.inObjectScope(.graph)

        container.register(POIListRouter.self) { _ in POIListRouter() }
            .inObjectScope(.graph)

        // MARK: — Scene: Map
        container.register((any POIMapViewModelProtocol).self) { r in
            POIMapViewModel(
                service: r.resolve(POIServiceProtocol.self)!,
                factory: DefaultAnnotationFactory()
            )
        }.inObjectScope(.graph)

        container.register(AnyPOIMapViewModel.self) { r in
            AnyPOIMapViewModel(r.resolve((any POIMapViewModelProtocol).self)!)
        }.inObjectScope(.graph)

        container.register(MapRouter.self) { _ in MapRouter() }
            .inObjectScope(.graph)

        // MARK: — Scene: Settings
        container.register((any SettingsViewModelProtocol).self) { r in
            SettingsViewModel(
                iapService:   r.resolve(IAPServiceProtocol.self)!,
                analytics:    r.resolve(AnalyticsServiceProtocol.self)!,
                notification: r.resolve(NotificationServiceProtocol.self)!
            )
        }.inObjectScope(.graph)

        container.register(AnySettingsViewModel.self) { r in
            AnySettingsViewModel(r.resolve((any SettingsViewModelProtocol).self)!)
        }.inObjectScope(.graph)

        // MARK: — Scene: POIDetail
        container.register(POIDetailViewModel.self) { _, poi in
            POIDetailViewModel(poi: poi)
        }
        // ВАЖНО: координатору даём resolver из Swinject
        container.register(POIDetailCoordinator.self) { r, poi in
            POIDetailCoordinator(poi: poi, resolver: r)
        }.inObjectScope(.graph)
    }

    // Потокобезопасный резолвер (локальный граф зависимостей)
    public var resolver: Resolver { container.synchronize() }
}
