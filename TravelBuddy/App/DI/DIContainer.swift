//
//  DIContainer.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/23/25.
//

import Foundation
import Swinject
import UIKit
import SwiftUI
import UserNotifications

@MainActor
public final class DIContainer {
    public static let shared = DIContainer()
    let container = Container()

    private init() {
        // 0) AppConfig —
        let config = AppConfig.makeDefault()
        container.register(AppConfig.self) { _ in config }
            .inObjectScope(.container)
      
        // DeepLink
        container.register(DeepLinkHandling.self) { _ in
            DeepLinkService()
        }.inObjectScope(.container)

        // 1) Core
        container.register(HTTPClientProtocol.self) { r in
            HTTPClient(timeout: r.resolve(AppConfig.self)!.httpTimeout)
        }.inObjectScope(.container)

        // 2) Services
        container.register(AnalyticsServiceProtocol.self) { _ in AnalyticsService() }
            .inObjectScope(.container)

        container.register(IAPServiceProtocol.self) { r in
            IAPService(config: r.resolve(AppConfig.self)!)
        }.inObjectScope(.container)

        container.register(IAPObserver.self) { r in
            IAPObserver(iap: r.resolve(IAPServiceProtocol.self)!)
        }.inObjectScope(.container)

        container.register(NotificationServiceProtocol.self) { _ in NotificationService() }
            .inObjectScope(.container)

        // 3) POI data stack
        container.register(RemotePOIService.self) { r in
            RemotePOIService(
                httpClient: r.resolve(HTTPClientProtocol.self)!,
                config: r.resolve(AppConfig.self)!
            )
        } // scope по умолчанию .graph — норм

        container.register(LocalPOIService.self) { r in
            LocalPOIService(config: r.resolve(AppConfig.self)!)
        }

        container.register(POICacheProtocol.self) { _ in RealmPOICache() }

        container.register(POIServiceProtocol.self) { r in
            POIRepository(
                remote: r.resolve(RemotePOIService.self)!,
                local:  r.resolve(LocalPOIService.self)!,
                cache:  r.resolve(POICacheProtocol.self)!,
                ttl:    r.resolve(AppConfig.self)!.poiCacheTTL
            )
        }.inObjectScope(.container)

        // 4) Onboarding
        container.register((any OnboardingViewModelProtocol).self) { _ in OnboardingViewModel() }
        container.register(AnyOnboardingViewModel.self) { r in
            AnyOnboardingViewModel(r.resolve((any OnboardingViewModelProtocol).self)!)
        }.inObjectScope(.graph)

        // 5) POIList scene
        container.register((any POIListViewModelProtocol).self) { r in
            POIListViewModel(repository: r.resolve(POIServiceProtocol.self)!)
        }.inObjectScope(.graph)

        container.register(AnyPOIListViewModel.self) { r in
            AnyPOIListViewModel(r.resolve((any POIListViewModelProtocol).self)!)
        }.inObjectScope(.graph)

        container.register(POIListRouter.self) { _ in POIListRouter() }
            .inObjectScope(.graph)

        // 6) Map scene
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

        // 7) Settings scene
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

        // 8) AppRouter и Detail
        container.register(AppRouter.self) { _ in AppRouter() }
            .inObjectScope(.container)

        container.register(POIDetailViewModel.self) { _, poi in
            POIDetailViewModel(poi: poi)
        }
        container.register(POIDetailCoordinator.self) { r, poi in
            POIDetailCoordinator(poi: poi, resolver: r)
        }.inObjectScope(.graph)
        
        //MARK: Push
        container.register(PushServiceProtocol.self) { _ in
            let svc = PushService()
            // Делегат центра нотификаций — сам сервис
            UNUserNotificationCenter.current().delegate = svc
            svc.registerCategories()
            return svc
        }
        .inObjectScope(.container)
        
        container.registerUITestOverridesIfNeeded()

    }

    public var resolver: Resolver { container.synchronize() }
}


private extension Container {
    /// Вызывать ПОСЛЕ базовых регистраций, чтобы в режиме UI-тестов переопределить сервисы.
    func registerUITestOverridesIfNeeded() {
        let useLocalOnly = AppFlags.isUITesting || AppFlags.useMockData
        guard useLocalOnly else { return }

        // Локальный сервис вместо сети/кэша
        self.register(POIServiceProtocol.self) { r in
            // Если у тебя LocalPOIService требует конфиг — разрезолвим его
            let config = r.resolve(AppConfig.self)!
            return LocalPOIService(config: config)
        }
        .inObjectScope(.container)

        // Если где-то регистрируется репозиторий (remote+cache),
        // эта регистрация перезатрёт его и всё будет читать локальный JSON.
    }
}
