//
//  DIContainer.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/23/25.
//


// 📂 TravelBuddy/Core/DIContainer.swift

import Foundation
import Swinject
import UIKit
import SwiftUI

public final class DIContainer {
    public static let shared = DIContainer()
    private let container = Container()

    private init() {
        // MARK: — Core
        container.register(HTTPClientProtocol.self) { _ in
            HTTPClient()
        }

        // MARK: — Services
        container.register(AnalyticsServiceProtocol.self) { _ in
            AnalyticsService()
        }
        container.register(IAPServiceProtocol.self) { _ in
            IAPService()
        }
        container.register(NotificationServiceProtocol.self) { _ in
            NotificationService()
        }

        // MARK: — Scene: Onboarding
        container.register((any OnboardingViewModelProtocol).self) { _ in
            OnboardingViewModel()
        }
        container.register(AnyOnboardingViewModel.self) { r in
            AnyOnboardingViewModel(
                r.resolve((any OnboardingViewModelProtocol).self)!
            )
        }

        // MARK: — Scene: POIList
        container.register(RemotePOIService.self) { r in
            RemotePOIService(httpClient: r.resolve(HTTPClientProtocol.self)!)
        }
        container.register(LocalPOIService.self) { _ in
            LocalPOIService()
        }
        container.register(POICacheProtocol.self) { _ in
            RealmPOICache()
        }
        container.register(POIServiceProtocol.self) { r in
            POIRepository(
                remote: r.resolve(RemotePOIService.self)!,
                local:  r.resolve(LocalPOIService.self)!,
                cache:  r.resolve(POICacheProtocol.self)!
            )
        }
        container.register((any POIListViewModelProtocol).self) { r in
            POIListViewModel(repository: r.resolve(POIServiceProtocol.self)!)
        }
        container.register(AnyPOIListViewModel.self) { r in
            AnyPOIListViewModel(
                r.resolve((any POIListViewModelProtocol).self)!
            )
        }
        // Router с MainActor
        container.register(POIListRouter.self) { _ in
            MainActor.assumeIsolated {
                POIListRouter()
            }
        }

        // MARK: — Scene: Map
        container.register((any POIMapViewModelProtocol).self) { r in
            POIMapViewModel(
                service: r.resolve(POIServiceProtocol.self)!,
                factory: DefaultAnnotationFactory()
            )
        }
        container.register(AnyPOIMapViewModel.self) { r in
            AnyPOIMapViewModel(
                r.resolve((any POIMapViewModelProtocol).self)!
            )
        }
        // Router с MainActor
        container.register(MapRouter.self) { _ in
            MainActor.assumeIsolated {
                MapRouter()
            }
        }

        // MARK: — Scene: Settings
        container.register((any SettingsViewModelProtocol).self) { r in
            SettingsViewModel(
                iapService:   r.resolve(IAPServiceProtocol.self)!,
                analytics:    r.resolve(AnalyticsServiceProtocol.self)!,
                notification: r.resolve(NotificationServiceProtocol.self)!
            )
        }
        container.register(AnySettingsViewModel.self) { r in
            AnySettingsViewModel(
                r.resolve((any SettingsViewModelProtocol).self)!
            )
        }

        // MARK: — Scene: POIDetail — регистрируем ***конкретный*** класс
            container.register(POIDetailViewModel.self) { _, poi in
                MainActor.assumeIsolated {
                    POIDetailViewModel(poi: poi)
                }
            }

            container.register(POIDetailCoordinator.self) { _, poi in
                // Координатор внутри себя достанет VM и View
                MainActor.assumeIsolated {
                    POIDetailCoordinator(poi: poi)
                }
            }
    }

    /// Resolve без аргумента
    public func resolve<T>(_ type: T.Type) -> T {
        guard let obj = container.resolve(type) else {
            fatalError("⚠️ Swinject: Не найдена регистрация для типа \(type)!")
        }
        return obj
    }

    /// Resolve с аргументом
    public func resolve<T, Arg>(_ type: T.Type, argument: Arg) -> T {
        guard let obj = container.resolve(type, argument: argument) else {
            fatalError("⚠️ Swinject: Не найдена регистрация для типа \(type) с аргументом \(Arg.self)!")
        }
        return obj
    }
}
