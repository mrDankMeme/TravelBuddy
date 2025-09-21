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

    public init(viewModel: AnyPOIMapViewModel,
                defaultRegionMeters: CLLocationDistance) {
        _vm = StateObject(wrappedValue: viewModel)
        self.defaultRegionMeters = defaultRegionMeters
    }

    public var body: some View {
        MapViewRepresentable(
            annotations: vm.annotations,
            defaultRegionMeters: defaultRegionMeters,
            onSelect: { annotation in router.goDetail(annotation.poi) }
        )
        .ignoresSafeArea()
        .onAppear { vm.fetch() }
    }
}
