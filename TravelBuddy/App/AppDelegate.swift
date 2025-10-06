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

        // Резолвим сервис из DI
        pushService = DIContainer.shared.resolver.resolve(PushServiceProtocol.self)

        // Назначаем делегата на центр уведомлений
        if let svc = pushService as? UNUserNotificationCenterDelegate {
            UNUserNotificationCenter.current().delegate = svc
        }

        // Регистрируем категории
        pushService?.registerCategories()

        return true
    }

    // APNs callbacks

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        pushService?.setDeviceToken(deviceToken)
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed:", error)
    }
}

