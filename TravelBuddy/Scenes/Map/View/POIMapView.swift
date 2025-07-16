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

    public init(viewModel: AnyPOIMapViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        MapViewRepresentable(
            annotations: vm.annotations,
            onSelect: { annotation in
                // при выборе точки — отправляем команду в роутер
                router.goDetail(annotation.poi)
            }
        )
        .ignoresSafeArea()
        .onAppear { vm.fetch() }
        .navigationTitle("Map")
    }
}
