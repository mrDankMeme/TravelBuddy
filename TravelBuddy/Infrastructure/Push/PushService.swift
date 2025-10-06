//
//  PushService.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 10/6/25.
//


import UIKit
import UserNotifications

@MainActor
public final class PushService: NSObject, PushServiceProtocol {
    private let center = UNUserNotificationCenter.current()
    private(set) public var apnsDeviceTokenHex: String?
    public var presentInForeground: Bool = true

    // MARK: Permissions

    public func getPermissionStatus() async -> PushPermissionStatus {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined: return .notDetermined
        case .denied:        return .denied
        case .authorized:    return .authorized
        case .provisional:   return .provisional
        case .ephemeral:     return .ephemeral
        @unknown default:    return .notDetermined
        }
    }

    public func requestPermission(options: PushOptions) async -> Bool {
        let opts: UNAuthorizationOptions = [
            options.contains(.alert) ? .alert : [],
            options.contains(.badge) ? .badge : [],
            options.contains(.sound) ? .sound : []
        ].reduce([] as UNAuthorizationOptions) { $0.union($1) }

        do {
            let granted = try await center.requestAuthorization(options: opts)
            await MainActor.run {
                UIApplication.shared.registerForRemoteNotifications()
            }
            return granted
        } catch {
            return false
        }
    }

    // MARK: APNs

    public func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }

    public func setDeviceToken(_ token: Data) {
        let hex = token.map { String(format: "%02x", $0) }.joined()
        apnsDeviceTokenHex = hex
        // TODO: отправь hex на бэкенд/в FCM при необходимости
        print("APNs token:", hex)
    }

    // MARK: Local

    public func scheduleLocal(title: String, body: String, after seconds: TimeInterval) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        content.sound = .default
        content.categoryIdentifier = PushCategoryFactory.defaultCategoryId

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(0.1, seconds), repeats: false)
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        try await center.add(req)
    }

    // MARK: Categories

    public func registerCategories() {
        center.setNotificationCategories(PushCategoryFactory.makeAll())
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PushService: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(presentInForeground ? [.banner, .list, .sound] : [])
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        // 1) Пробуем извлечь deep link из payload
        if let url = PushPayload.deeplink(from: response.notification.request.content.userInfo) {
            // 2) Передаём в ТВОЙ DeepLinkService (через DI)
            DIContainer.shared.resolver
                .resolve(DeepLinkHandling.self)?
                .handle(url: url)
        }
        completionHandler()
    }
}
