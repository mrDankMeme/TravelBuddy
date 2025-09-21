//
//  MapCoordinator.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/10/25.
//


import SwiftUI
import Combine
import MapKit

@MainActor
final class MapCoordinator {
    private let vm: AnyPOIMapViewModel
    private let router: MapRouter
    private let defaultRegionMeters: CLLocationDistance
    private let makeDetail: (POI) -> AnyView
    
    init(vm: AnyPOIMapViewModel, router: MapRouter) {
        self.vm     = vm
        self.router = router
        
        let config = DIContainer.shared.resolver.resolve(AppConfig.self)!
        self.defaultRegionMeters = config.defaultRegionMeters
        let resolver = DIContainer.shared.resolver
        self.makeDetail = { poi in
            guard let coord = resolver.resolve(POIDetailCoordinator.self, argument: poi) else {
                return AnyView(EmptyView())
            }
            return AnyView(coord.rootView())
        }
    }
    
    func rootView() -> some View {
        MapContainer(vm: vm, router: router, defaultRegionMeters: defaultRegionMeters, makeDetail: makeDetail)
    }
}

