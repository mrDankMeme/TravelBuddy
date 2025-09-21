//
//  AppConfig.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 9/19/25.
//


import Foundation
import CoreLocation

public struct AppConfig {
    // MARK: — Network
    public let apiBaseURL: URL
    public let httpTimeout: TimeInterval

    // MARK: — Repository / Cache
    public let poiCacheTTL: TimeInterval

    // MARK: — IAP
    public struct IAP {
        public let premiumProductID: String
    }
    public let iap: IAP

    // MARK: — Local data / mocks
    public let localPOIJSONName: String

    // MARK: — Map defaults
    public let defaultRegionMeters: CLLocationDistance

    // MARK: — Feature Flags
    public struct Flags {
        public let enableDebugLogs: Bool
        public let useAlamofireClient: Bool  // на будущее
        public let showBLETab: Bool          // на будущее
        public let enableAudioGuide: Bool    // на будущее
    }
    public let flags: Flags
}


public extension AppConfig {
    static func makeDefault() -> AppConfig {
        #if DEBUG
        return AppConfig(
            apiBaseURL: URL(string: "https://api.example.com")!,
            httpTimeout: 0.15 ,
            poiCacheTTL: 300,
            iap: .init(premiumProductID: "com.travelbuddy.premium"),
            localPOIJSONName: "mock_pois_local",
            defaultRegionMeters: 4000,
            flags: .init(
                enableDebugLogs: true,
                useAlamofireClient: false,
                showBLETab: false,
                enableAudioGuide: false
            )
        )
        #else
        return AppConfig(
            apiBaseURL: URL(string: "https://api.example.com")!,
            httpTimeout: 15,
            poiCacheTTL: 300,
            iap: .init(premiumProductID: "com.travelbuddy.premium"),
            localPOIJSONName: "mock_pois_local",
            defaultRegionMeters: 4000,
            flags: .init(
                enableDebugLogs: false,
                useAlamofireClient: false,
                showBLETab: false,
                enableAudioGuide: false
            )
        )
        #endif
    }
}
