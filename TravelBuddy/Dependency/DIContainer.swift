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
        container.register(RemotePOIService.self) { r in
               RemotePOIService(httpClient: r.resolve(HTTPClientProtocol.self)!)
           }
           container.register(LocalPOIService.self) { _ in
               LocalPOIService()
           }
           container.register(POICacheProtocol.self) { _ in
               RealmPOICache()
           }
           // Репозиторий, собирающий их вместе (фасад)
           container.register(POIServiceProtocol.self) { r in
               POIRepository(
                   remote: r.resolve(RemotePOIService.self)!,
                   local: r.resolve(LocalPOIService.self)!,
                   cache: r.resolve(POICacheProtocol.self)!
               )
           }
        
        container.register(POIListViewModelProtocol.self) { r in
            POIListViewModel(repository: r.resolve(POIServiceProtocol.self)!)
        }
        container.register(AnyPOIListViewModel.self) { r in
            AnyPOIListViewModel(r.resolve(POIListViewModelProtocol.self)!)
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
