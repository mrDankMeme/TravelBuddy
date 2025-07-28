//
//  MapContainer.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/17/25.
//


import SwiftUI
import Combine

struct MapContainer: View {
    // ---------- State ----------
    @State private var navPath = NavigationPath()
    @StateObject private var router: MapRouter
    @StateObject private var vm: AnyPOIMapViewModel

    // ---------- Init ----------
    init(vm: AnyPOIMapViewModel, router: MapRouter) {
        _vm     = StateObject(wrappedValue: vm)
        _router = StateObject(wrappedValue: router)
    }

    // ---------- UI ----------
    var body: some View {
        NavigationStack(path: $navPath) {
            POIMapView(viewModel: vm)
                .navigationDestination(for: MapRoute.self) { route in
                    switch route {
                    case .detail(let poi):
                        DIContainer.shared
                            .resolve(POIDetailCoordinator.self, argument: poi)
                            .rootView()
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
