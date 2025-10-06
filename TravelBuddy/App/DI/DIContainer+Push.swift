//
//  DIContainer+Push.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 10/6/25.
//


import Swinject
import UserNotifications

extension DIContainer {
    func registerPush() {
        container.register(PushServiceProtocol.self) { _ in
            let svc = PushService()
            // Делегат центра нотификаций — сам сервис
            UNUserNotificationCenter.current().delegate = svc
            svc.registerCategories()
            return svc
        }
        .inObjectScope(.container)
    }
}
