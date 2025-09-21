//
//  MapContainer.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/17/25.
//


import SwiftUI
import Combine
import Swinject
import MapKit

struct MapContainer: View {
    // ---------- State ----------
    @State private var navPath = NavigationPath()
    @StateObject private var router: MapRouter
    @StateObject private var vm: AnyPOIMapViewModel
    private let defaultRegionMeters: CLLocationDistance
    private let makeDetail: (POI) -> AnyView

    init(vm: AnyPOIMapViewModel, router: MapRouter, defaultRegionMeters: CLLocationDistance,makeDetail: @escaping (POI) -> AnyView) {
        _vm = StateObject(wrappedValue: vm)
        _router = StateObject(wrappedValue: router)
        self.defaultRegionMeters = defaultRegionMeters
        self.makeDetail = makeDetail
    }

    // ---------- UI ----------
    var body: some View {
        NavigationStack(path: $navPath) {
            POIMapView(viewModel: vm, defaultRegionMeters: defaultRegionMeters)
                .navigationDestination(for: MapRoute.self) { route in
                    switch route {
                    case .detail(let poi):
                        let r = DIContainer.shared.resolver
                        r.resolve(POIDetailCoordinator.self, argument: poi)?
                            .rootView()
                        makeDetail(poi)
                    }
                }
        }
        // -------- Router → NavigationPath --------
        .onReceive(router.routes) { command in
            switch command {
            case .detail(let poi):
                navPath.append(MapRoute.detail(poi))

            case .back:
                if !navPath.isEmpty { navPath.removeLast() }

            case .reset:
                navPath.removeLast(navPath.count)
            }
        }
        .environmentObject(router)   // нужен внутри POIMapView
    }
}
