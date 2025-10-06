//
//  NoopPushService.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 10/6/25.
//



import Foundation

@MainActor
final class NoopPushService: PushServiceProtocol {
    var apnsDeviceTokenHex: String? = nil
    var presentInForeground: Bool = false

    func getPermissionStatus() async -> PushPermissionStatus { .denied }
    func requestPermission(options: PushOptions) async -> Bool { false }
    func registerForRemoteNotifications() {}
    func setDeviceToken(_ token: Data) {}
    func scheduleLocal(title: String, body: String, after seconds: TimeInterval) async throws {}
    func registerCategories() {}
}
