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

/// Контейнер управляет:
/// - NavigationStack (деталью)
/// - подпиской на команды MapRouter (detail/back/reset/center/focusPOI)
/// - согласованием deeplink-команд с VM (выбор POI) и MapView (центрирование)
struct MapContainer: View {
    @State private var path: [MapRoute] = []
    @State private var prevPathCount: Int = 0

    @State private var lastPushedPOIId: Int?
    @State private var isNavigating = false

    @StateObject private var router: MapRouter
    @StateObject private var vm: AnyPOIMapViewModel

    private let defaultRegionMeters: CLLocationDistance
    private let makeDetail: (POI) -> AnyView

    // deeplink-команда центрирования — одноразовый триггер для MapViewRepresentable
    @State private var centerRequest: CLLocationCoordinate2D? = nil

    // pending focus, если аннотации еще не загружены
    @State private var pendingFocusId: Int? = nil

    init(
        vm: AnyPOIMapViewModel,
        router: MapRouter,
        defaultRegionMeters: CLLocationDistance,
        makeDetail: @escaping (POI) -> AnyView
    ) {
        _vm = StateObject(wrappedValue: vm)
        _router = StateObject(wrappedValue: router)
        self.defaultRegionMeters = defaultRegionMeters
        self.makeDetail = makeDetail
    }

    var body: some View {
            NavigationStack(path: $path) {
                POIMapView(
                    viewModel: vm,
                    defaultRegionMeters: defaultRegionMeters,
                    centerRequest: $centerRequest
                )
                .navigationDestination(for: MapRoute.self) { route in
                    switch route {
                    case .detail(let poi):
                        makeDetail(poi)
                    }
                }
            }
            // 1) горячие — как было
            .onReceive(router.routes) { command in
                handle(command)
            }
            // 2) холодные — забрать из буфера при первом появлении
            .onAppear {
                router.consumePending().forEach { cmd in
                    handle(cmd)
                }
            }
            // остальное без изменений ...
            .onChange(of: path) { newValue in
                if newValue.count < prevPathCount {
                    lastPushedPOIId = nil
                    isNavigating = false
                }
                prevPathCount = newValue.count
            }
            .onChange(of: vm.annotations) { _ in
                if let id = pendingFocusId,
                   let poi = vm.annotations.first(where: { $0.poi.id == id })?.poi {
                    pendingFocusId = nil
                    vm.selectedPOI = poi
                }
            }
            .environmentObject(router)
        }

        // Единая обработка команд — используем и для горячих, и для холодных
        private func handle(_ command: MapNavigationCommand) {
            switch command {
            case .detail(let poi):
                guard !isNavigating, lastPushedPOIId != poi.id else { return }
                isNavigating = true
                path.append(.detail(poi))
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

            case .center(let coord):
                centerRequest = coord   // триггер для MapViewRepresentable

            case .focusPOI(let id):
                if let poi = vm.annotations.first(where: { $0.poi.id == id })?.poi {
                    vm.selectedPOI = poi
                } else {
                    pendingFocusId = id
                    vm.fetch()
                }
            }
        }
    }
