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
            selectedId: Binding(
                get: { vm.selectedPOI?.id },
                set: { newId in
                    vm.selectedPOI = newId.flatMap { id in
                        vm.annotations.first(where: { $0.poi.id == id })?.poi
                    }
                }
            ),
            centerRequest: $centerRequest,
            onSelect: { _ in }
        )
        .ignoresSafeArea()
        .onAppear { vm.fetch() }
        .sheet(item: Binding(
            get: { vm.selectedPOI },
            set: { vm.selectedPOI = $0 }
        ), onDismiss: {
            vm.selectedPOI = nil
        }) { poi in
            POISnippetView(
                poi: poi,
                onDetails: {
                    vm.selectedPOI = nil
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
