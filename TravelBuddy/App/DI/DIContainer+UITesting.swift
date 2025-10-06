//
//  DIContainer+UITesting.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 10/6/25.
//


//  TravelBuddy/App/DI/DIContainer+UITesting.swift
import Foundation
import Swinject

extension Container {
    /// Вызывать ПОСЛЕ базовых регистраций, чтобы в режиме UI-тестов переопределить сервисы.
    func registerUITestOverridesIfNeeded() {
        let useLocalOnly = AppFlags.isUITesting || AppFlags.useMockData
        guard useLocalOnly else { return }

        // Локальный сервис вместо сети/кэша
        self.register(POIServiceProtocol.self) { r in
            // Если у тебя LocalPOIService требует конфиг — разрезолвим его
            let config = r.resolve(AppConfig.self)!
            return LocalPOIService(config: config)
        }
        .inObjectScope(.container)

        // Если где-то регистрируется репозиторий (remote+cache),
        // эта регистрация перезатрёт его и всё будет читать локальный JSON.
    }
}
