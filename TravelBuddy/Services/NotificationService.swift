//
//  NotificationService.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/20/25.
//


import UserNotifications
import Combine

public protocol NotificationServiceProtocol {
  func requestAuthorization() -> AnyPublisher<Bool, Never>
  func schedule(_ content: UNNotificationContent, at date: Date)
}

public final class NotificationService: NotificationServiceProtocol {
  public init() {}

  public func requestAuthorization() -> AnyPublisher<Bool, Never> {
    Future { promise in
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound]) { granted, _ in
          promise(.success(granted))
        }
    }
    .eraseToAnyPublisher()
  }

  public func schedule(_ content: UNNotificationContent, at date: Date) {
    let interval = max(1, date.timeIntervalSinceNow)
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
    let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(req)
  }
}
