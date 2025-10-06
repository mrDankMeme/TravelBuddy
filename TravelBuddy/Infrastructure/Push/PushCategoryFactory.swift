//
//  PushCategoryFactory.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 10/6/25.
//


import UserNotifications

public enum PushCategoryFactory {
    public static let defaultCategoryId = "APP_DEFAULT"

    public static func makeAll() -> Set<UNNotificationCategory> {
        let open = UNNotificationAction(
            identifier: "OPEN_APP",
            title: "Open",
            options: [.foreground]
        )
        let cat = UNNotificationCategory(
            identifier: defaultCategoryId,
            actions: [open],
            intentIdentifiers: [],
            options: []
        )
        return [cat]
    }
}
