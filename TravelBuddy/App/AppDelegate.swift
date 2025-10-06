//
//  AppDelegate.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/19/25.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var pushService: PushServiceProtocol?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // resolve
        pushService = DIContainer.shared.resolver.resolve(PushServiceProtocol.self)

        // назначаем делегата и регистрируем категории ТУТ
        if let svc = pushService as? UNUserNotificationCenterDelegate {
            UNUserNotificationCenter.current().delegate = svc
        }
        pushService?.registerCategories()

        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        pushService?.setDeviceToken(deviceToken)
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed:", error)
    }
}
