//
//  AnalyticsService.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/20/25.
//

import FirebaseAnalytics
import FirebaseCrashlytics


public final class AnalyticsService: AnalyticsServiceProtocol {
  public init() {}
  public func logEvent(name: String, parameters: [String: Any]?) {
    Analytics.logEvent(name, parameters: parameters)
  }
  public func recordError(_ error: Error) {
    Crashlytics.crashlytics().record(error: error)
  }
}
