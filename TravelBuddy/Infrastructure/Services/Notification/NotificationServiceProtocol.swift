//
//  NotificationServiceProtocol.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/28/25.
//


import UserNotifications
import Combine

public protocol NotificationServiceProtocol {
  func requestAuthorization() -> AnyPublisher<Bool, Never>
  func schedule(_ content: UNNotificationContent, at date: Date)
}
