//
//  MapRoute.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/11/25.
//

import SwiftUI
import Combine
import CoreLocation

enum MapRoute: Hashable {
    case detail(POI)
}

enum MapNavigationCommand {
    case detail(POI)
    case back
    case reset
    case center(CLLocationCoordinate2D) // deeplink: travelbuddy://map?lat&lon
    case focusPOI(Int)                  // deeplink: travelbuddy://poi/<id>
}

@MainActor
final class MapRouter: ObservableObject {
    fileprivate var cancellables = Set<AnyCancellable>()
    let routes = PassthroughSubject<MapNavigationCommand, Never>()

    // MARK: — High-level API

    func goDetail(_ poi: POI) {
        routes.send(.detail(poi))
    }

    func goBack() {
        routes.send(.back)
    }

    func reset() {
        routes.send(.reset)
    }

    // Deeplink hooks
    func center(on coord: CLLocationCoordinate2D) {
        routes.send(.center(coord))
    }

    func focusPOI(_ id: Int) {
        routes.send(.focusPOI(id))
    }
}
