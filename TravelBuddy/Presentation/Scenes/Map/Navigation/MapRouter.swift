//
//  MapRoute.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/11/25.
//


import SwiftUI
import Combine

enum MapRoute: Hashable {
    case detail(POI)
}

enum MapNavigationCommand {
    case detail(POI)
    case back
    case reset
}

@MainActor
final class MapRouter: ObservableObject {
    fileprivate var cancellables = Set<AnyCancellable>()
    let routes = PassthroughSubject<MapNavigationCommand, Never>()

    func goDetail(_ poi: POI) {
        routes.send(MapNavigationCommand.detail(poi))
    }

    func goBack() {
        routes.send(MapNavigationCommand.back)
    }

    func reset() {
        routes.send(MapNavigationCommand.reset)
    }
}