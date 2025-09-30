//
//  SceneDelegate.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/19/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var coordinator: AppCoordinator?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let ws = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: ws)
        self.window = window

        coordinator = AppCoordinator(window: window)
        coordinator?.start()

        // 🔗 обрабатываем диплинк при холодном старте
        if let url = connectionOptions.urlContexts.first?.url {
            DIContainer.shared.resolver
                .resolve(DeepLinkHandling.self)?
                .handle(url: url)
        }
    }

    // 🔗 диплинки в уже запущенное приложение
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        DIContainer.shared.resolver
            .resolve(DeepLinkHandling.self)?
            .handle(url: url)
    }
}

