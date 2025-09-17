//
//  AppRouter.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 9/12/25.
//


import Combine

@MainActor
public final class AppRouter: ObservableObject {
    public let events = PassthroughSubject<AppRoute, Never>()
    public init() {}
    public func send(_ route: AppRoute) { events.send(route) }
}
