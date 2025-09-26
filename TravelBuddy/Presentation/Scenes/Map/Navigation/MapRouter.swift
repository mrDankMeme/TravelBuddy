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
    case center(CLLocationCoordinate2D)
    case focusPOI(Int)
    case showError(String)
}


@MainActor
final class MapRouter: ObservableObject {
    fileprivate var cancellables = Set<AnyCancellable>()
    let routes = PassthroughSubject<MapNavigationCommand, Never>()

    // Буфер для команд, пришедших до подписки UI
    private var pending: [MapNavigationCommand] = []

    // Единая точка эмита: и шлём, и буферизуем
    private func emit(_ cmd: MapNavigationCommand) {
        pending.append(cmd)
        routes.send(cmd)
    }

    // Забрать и обнулить буфер (для MapContainer.onAppear)
    func consumePending() -> [MapNavigationCommand] {
        let items = pending
        pending.removeAll()
        return items
    }

    // MARK: — High-level API
    func goDetail(_ poi: POI)       { emit(.detail(poi)) }
    func goBack()                    { emit(.back) }
    func reset()                     { emit(.reset) }
    func center(on coord: CLLocationCoordinate2D) { emit(.center(coord)) }
    func focusPOI(_ id: Int)         { emit(.focusPOI(id)) }
    func showError(_ message: String) { emit(.showError(message)) }
}
