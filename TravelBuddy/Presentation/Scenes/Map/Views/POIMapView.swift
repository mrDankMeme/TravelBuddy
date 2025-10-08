//
//  POIMapView.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/7/25.
//

//
//  POIMapView.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/7/25.
//

import SwiftUI
import MapKit

/// Владеет `AnyPOIMapViewModel`, показывает карту и сниппет.
/// Управление фокусом и центрированием приходит сверху через биндинги.
public struct POIMapView: View {
    @StateObject private var vm: AnyPOIMapViewModel
    @EnvironmentObject private var router: MapRouter
    private let defaultRegionMeters: CLLocationDistance

    /// Прокидываем из `MapContainer` запросы центра/фокуса
    @Binding private var centerRequest: CLLocationCoordinate2D?

    // ✅ Локальный буфер выбора пина.
    // Карта пишет СЮДА, а мы уже ПОТОМ синхронизируем это с VM.
    @State private var selectedId: Int? = nil

    public init(
        viewModel: AnyPOIMapViewModel,
        defaultRegionMeters: CLLocationDistance,
        centerRequest: Binding<CLLocationCoordinate2D?>
    ) {
        _vm = StateObject(wrappedValue: viewModel)
        self.defaultRegionMeters = defaultRegionMeters
        self._centerRequest = centerRequest
    }

    public var body: some View {
        MapViewRepresentable(
            annotations: vm.annotations,
            defaultRegionMeters: defaultRegionMeters,
            selectedId: $selectedId,
            centerRequest: $centerRequest,
            onSelect: { _ in }
        )
        .ignoresSafeArea()
        .onAppear {
            vm.fetch()
            selectedId = vm.selectedPOI?.id
        }
        .onChange(of: selectedId) { newId in
            vm.selectedPOI = newId.flatMap { id in
                vm.annotations.first(where: { $0.poi.id == id })?.poi
            }
        }
        .onChange(of: vm.selectedPOI?.id) { id in
            if selectedId != id { selectedId = id }
        }
        .sheet(
            item: Binding(
                get: { vm.selectedPOI },
                set: { vm.selectedPOI = $0 }
            ),
            onDismiss: {
                vm.selectedPOI = nil
                selectedId = nil
            }
        ) { poi in
            POISnippetView(
                poi: poi,
                onDetails: {
                    vm.selectedPOI = nil
                    selectedId = nil
                    // Переход в детали — ассинхронно, чтобы не мешать закрытию шита.
                    DispatchQueue.main.async { router.goDetail(poi) }
                },
                onRoute: {
                    let coord = CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude)
                    let item = MKMapItem(placemark: MKPlacemark(coordinate: coord))
                    item.name = poi.name
                    item.openInMaps()
                }
            )
            .presentationDetents([.height(200), .medium])
        }
    }
}
