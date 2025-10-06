//
//  PushPermissionStatus.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 10/6/25.
//


import Foundation

public enum PushPermissionStatus {
    case notDetermined, denied, authorized, provisional, ephemeral
}

public protocol PushServiceProtocol: AnyObject {
    // Permissions
    func getPermissionStatus() async -> PushPermissionStatus
    func requestPermission(options: PushOptions) async -> Bool

    // APNs registration
    func registerForRemoteNotifications()
    func setDeviceToken(_ token: Data)
    var apnsDeviceTokenHex: String? { get }

    // Local notifications (for tests / reminders)
    func scheduleLocal(title: String, body: String, after seconds: TimeInterval) async throws

    // Categories / Actions
    func registerCategories()

    // Foreground presentation policy
    var presentInForeground: Bool { get set }
}

public struct PushOptions: OptionSet {
    public let rawValue: Int
    public static let alert = PushOptions(rawValue: 1 << 0)
    public static let badge = PushOptions(rawValue: 1 << 1)
    public static let sound = PushOptions(rawValue: 1 << 2)
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static let all: PushOptions = [.alert, .badge, .sound]
}
