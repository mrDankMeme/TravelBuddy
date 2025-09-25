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
    // ⬇️ было: private var navPath = NavigationPath()
    @State private var path: [MapRoute] = []             // ✅ типизированный путь
    @State private var prevPathCount: Int = 0            // ✅ следим за уменьшением стека

    @State private var lastPushedPOIId: Int?
    @State private var isNavigating = false

    @StateObject private var router: MapRouter
    @StateObject private var vm: AnyPOIMapViewModel

    private let defaultRegionMeters: CLLocationDistance
    private let makeDetail: (POI) -> AnyView

    init(vm: AnyPOIMapViewModel,
         router: MapRouter,
         defaultRegionMeters: CLLocationDistance,
         makeDetail: @escaping (POI) -> AnyView) {
        _vm = StateObject(wrappedValue: vm)
        _router = StateObject(wrappedValue: router)
        self.defaultRegionMeters = defaultRegionMeters
        self.makeDetail = makeDetail
    }

    // ---------- UI ----------
    var body: some View {
        NavigationStack(path: $path) {
            POIMapView(viewModel: vm, defaultRegionMeters: defaultRegionMeters)
                .navigationDestination(for: MapRoute.self) { route in
                    switch route {
                    case .detail(let poi):
                        makeDetail(poi)                    // ← один-единственный экран
                    }
                }
        }
        // -------- Router → NavigationPath --------
        .onReceive(router.routes) { command in
            switch command {
            case .detail(let poi):
                guard !isNavigating, lastPushedPOIId != poi.id else { return }
                isNavigating = true
                path.append(.detail(poi))                 // ← работаем с типизированным путём
                lastPushedPOIId = poi.id
                DispatchQueue.main.async { isNavigating = false }

            case .back:
                if !path.isEmpty { path.removeLast() }
                lastPushedPOIId = nil
                isNavigating = false

            case .reset:
                path.removeAll()
                lastPushedPOIId = nil
                isNavigating = false
            }
        }
   
        .onChange(of: path) { newValue in
            if newValue.count < prevPathCount {
                lastPushedPOIId = nil
                isNavigating = false
            }
            prevPathCount = newValue.count
        }
        .environmentObject(router)
    }
}

