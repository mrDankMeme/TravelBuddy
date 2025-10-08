//
//  ThemeServiceProtocol.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 10/7/25.
//

import Combine

/// Абстракция политики темы (не UI/UIKit)
public protocol ThemeServiceProtocol {
    /// Текущая настройка тёмной темы
    var isDark: Bool { get set }
    /// Поток изменений темы
    var changes: AnyPublisher<Bool, Never> { get }
}
