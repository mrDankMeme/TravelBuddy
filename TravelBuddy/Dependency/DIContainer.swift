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

public final class DIContainer {
    public static let shared = DIContainer()
    private let container = Container()

    private init() {
        // MARK: — Core
        container.register(HTTPClientProtocol.self) { _ in HTTPClient() }

        // MARK: — Services
        container.register(AnalyticsServiceProtocol.self) { _ in AnalyticsService() }
        container.register(IAPServiceProtocol.self) { _ in IAPService() }
        container.register(NotificationServiceProtocol.self) { _ in NotificationService() }
      
        //MARK: - Feature: Onboarding
        container.register((any OnboardingViewModelProtocol).self) { _ in
          OnboardingViewModel()
        }
        container.register(AnyOnboardingViewModel.self) { r in
             AnyOnboardingViewModel(
                 r.resolve((any OnboardingViewModelProtocol).self)!
             )
         }
     
       
        // MARK: — Feature: POIList
        container.register(POIServiceProtocol.self) { r in
            POIService(httpClient: r.resolve(HTTPClientProtocol.self)!)
        }

        container.register(POIListViewModel.self) { r in
            POIListViewModel(
                poiService: r.resolve(POIServiceProtocol.self)!,
                analytics: r.resolve(AnalyticsServiceProtocol.self)!,
                notification: r.resolve(NotificationServiceProtocol.self)!
            )
        }

        container.register(POIListViewController.self) { r in
            POIListViewController(viewModel: r.resolve(POIListViewModel.self)!)
        }

        // MARK: — Feature: Settings
        container.register((any SettingsViewModelProtocol).self) { r in
            SettingsViewModel(
                iapService: r.resolve(IAPServiceProtocol.self)!,
                analytics: r.resolve(AnalyticsServiceProtocol.self)!,
                notification: r.resolve(NotificationServiceProtocol.self)!
            )
        }

        container.register(AnySettingsViewModel.self) { r in
            AnySettingsViewModel(r.resolve((any SettingsViewModelProtocol).self)!)
        }
    }

    public func resolve<T>(_ type: T.Type) -> T {
        guard let resolved = container.resolve(type) else {
            fatalError("⚠️ Swinject: Не найдена регистрация для типа \(type)!")
        }
        return resolved
    }

}
