//
//  SceneDelegate.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/19/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    guard let ws = (scene as? UIWindowScene) else { return }
    let window = UIWindow(windowScene: ws)
    self.window = window

    // Инициализируем и запускаем координатор
    let coordinator = AppCoordinator(window: window)
    coordinator.start()
  }
}

