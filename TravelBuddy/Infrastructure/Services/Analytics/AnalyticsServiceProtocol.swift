//
//  AnalyticsServiceProtocol.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/28/25.
//


import Foundation

public protocol AnalyticsServiceProtocol {
  func logEvent(name: String, parameters: [String: Any]?)
  func recordError(_ error: Error)
}
