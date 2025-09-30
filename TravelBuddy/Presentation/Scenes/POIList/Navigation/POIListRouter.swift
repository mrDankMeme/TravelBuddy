//
//  POIListRoute.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/11/25.
//



import SwiftUI
import Combine

enum POIListRoute: Hashable {
    case detail(POI)
}

enum POIListUIError: Hashable {
    case plain(String)
    var localizedMessage: String {
        switch self {
        case .plain(let m): return m
        }
    }
}

enum POIListNavigationCommand {
    case detail(POI)
    case back
    case reset
    case showError(POIListUIError)
}

@MainActor
final class POIListRouter: ObservableObject {
    let routes = PassthroughSubject<POIListNavigationCommand, Never>()
    var cancellables = Set<AnyCancellable>()

    func goDetail(_ poi: POI) { routes.send(.detail(poi)) }
    func goBack() { routes.send(.back) }
    func reset() { routes.send(.reset) }

    func showError(_ error: POIListUIError) { routes.send(.showError(error)) }
}
