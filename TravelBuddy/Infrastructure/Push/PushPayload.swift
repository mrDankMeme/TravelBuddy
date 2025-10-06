//
//  PushPayload.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 10/6/25.
//

import Foundation

enum PushPayload {
    /// Ожидаем кастомное поле "deeplink": "travelbuddy://poi/123"
    static func deeplink(from userInfo: [AnyHashable: Any]) -> URL? {
        guard
            let raw = userInfo["deeplink"] as? String,
            let url = URL(string: raw),
            url.scheme?.lowercased() == "travelbuddy"
        else { return nil }
        return url
    }
}
