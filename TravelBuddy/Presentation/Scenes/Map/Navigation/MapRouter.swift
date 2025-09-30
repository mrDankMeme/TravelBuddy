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

/// Только UI-ошибки карты, готовые к показу.
enum MapUIError: Equatable {
    case poiNotFound(Int)
    case plain(String)

    var localizedMessage: String {
        switch self {
        case .poiNotFound(let id):
            return L10n.deeplinkPoiNotFound(id)
        case .plain(let message):
            return message
        }
    }
}

enum MapNavigationCommand {
    case detail(POI)
    case back
    case reset
    case center(CLLocationCoordinate2D)
    case focusPOI(Int)
    case showError(MapUIError)
}

@MainActor
final class MapRouter: ObservableObject {
    let routes = PassthroughSubject<MapNavigationCommand, Never>()
    private var pending: [MapNavigationCommand] = []

    private func emit(_ cmd: MapNavigationCommand) {
        pending.append(cmd)
        routes.send(cmd)
    }

    func consumePending() -> [MapNavigationCommand] {
        let items = pending
        pending.removeAll()
        return items
    }

    // MARK: High-level API
    func goDetail(_ poi: POI)                 { emit(.detail(poi)) }
    func goBack()                              { emit(.back) }
    func reset()                               { emit(.reset) }
    func center(on coord: CLLocationCoordinate2D) { emit(.center(coord)) }
    func focusPOI(_ id: Int)                   { emit(.focusPOI(id)) }

    // Единый способ показать ошибку на карте
    func showError(_ error: MapUIError)        { emit(.showError(error)) }
}
