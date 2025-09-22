//
//  POIMapView.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/7/25.
//



import SwiftUI
import MapKit

public struct POIMapView: View {
    @StateObject private var vm: AnyPOIMapViewModel
    @EnvironmentObject private var router: MapRouter
    private let defaultRegionMeters: CLLocationDistance

    public init(viewModel: AnyPOIMapViewModel, defaultRegionMeters: CLLocationDistance) {
        _vm = StateObject(wrappedValue: viewModel)
        self.defaultRegionMeters = defaultRegionMeters
    }

    public var body: some View {
        MapViewRepresentable(
            annotations: vm.annotations,
            defaultRegionMeters: defaultRegionMeters,
            selectedId: Binding(
                get: { vm.selectedPOI?.id },                                  // ← биндим id
                set: { newId in
                    // выбор на карте → находим POI и кладём в VM (для сниппета)
                    vm.selectedPOI = newId.flatMap { id in
                        vm.annotations.first(where: { $0.poi.id == id })?.poi
                    }
                }
            ),
            onSelect: { _ in } // выбор обрабатываем через биндинг; прямой коллбек не нужен
        )
        .ignoresSafeArea()
        .onAppear { vm.fetch() }
        .sheet(item: Binding(
            get: { vm.selectedPOI },
            set: { vm.selectedPOI = $0 }
        ), onDismiss: {
            // 🔑 Закрыли сниппет → биндинг selectedId станет nil → MapView снимет highlight
            vm.selectedPOI = nil
        }) { poi in
            POISnippetView(
                poi: poi,
                onDetails: {
                    // 1) закрыть сниппет (это снимет выделение пина через биндинг)
                    vm.selectedPOI = nil
                    // 2) навигация командой в роутер (как и раньше)
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
