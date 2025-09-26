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
    @State private var focusTimeoutWorkItem: DispatchWorkItem? = nil
    @State private var failAlert: FailAlert? = nil
    
    private struct FailAlert: Identifiable {
        let id = UUID()
        let message: String
    }
    
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
        .onReceive(router.routes) { command in
            handle(command)
        }
        .onAppear {
            router.consumePending().forEach { cmd in
                handle(cmd)
            }
        }
        .onChange(of: path) { newValue in
            if newValue.count < prevPathCount {
                lastPushedPOIId = nil
                isNavigating = false
            }
            prevPathCount = newValue.count
        }
        .onChange(of: vm.annotations) { _ in
            // если ждали конкретный id — пробуем резолвнуть сейчас
            if let id = pendingFocusId,
               let poi = vm.annotations.first(where: { $0.poi.id == id })?.poi {
                pendingFocusId = nil
                cancelFocusTimeout()
                vm.selectedPOI = poi
            }
        }
        .alert(item: $failAlert) { alert in
            Alert(
                title: Text("Place not found"),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .environmentObject(router)
    }
    
    //Place not found вспомогательные методы
    private func scheduleFocusTimeout(for id: Int, seconds: Double = 2.5) {
        cancelFocusTimeout()

        let work = DispatchWorkItem {   // ВАЖНО: без [weak self], это struct
            // если всё ещё ждём этот же id, а selected не совпал — показываем фэйл
            if pendingFocusId == id, vm.selectedPOI?.id != id {
                failAlert = .init(
                    message: "We couldn't open place #\(id). It may be unavailable or not loaded yet."
                )

                // чуть подвинем карту, чтобы не оставлять «никуда»
                if let anyAnno = vm.annotations.first {
                    centerRequest = anyAnno.coordinate
                }

                // (опционально) лог
                DIContainer.shared.resolver
                    .resolve(AnalyticsServiceProtocol.self)?
                    .logEvent(name: "deeplink_poi_not_found", parameters: ["id": id])

                // сброс ожидания
                pendingFocusId = nil
            }
        }

        focusTimeoutWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: work)
    }
    
    private func cancelFocusTimeout() {
        focusTimeoutWorkItem?.cancel()
        focusTimeoutWorkItem = nil
    }
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
            centerRequest = coord
            
        case .focusPOI(let id):
            // пробуем сразу — вдруг уже загружено
            if let poi = vm.annotations.first(where: { $0.poi.id == id })?.poi {
                vm.selectedPOI = poi
                cancelFocusTimeout()
            } else {
                // включаем «ожидание» и таймер fail-safe
                pendingFocusId = id
                vm.fetch()                       // подтягиваем аннотации
                scheduleFocusTimeout(for: id)    // если не приедет — покажем алерт
            }
        case .showError(let message):
                failAlert = .init(message: message)
        }
    }
}
