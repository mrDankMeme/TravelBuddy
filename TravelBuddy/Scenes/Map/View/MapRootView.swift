//
//  MapRootView.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/10/25.
//


import SwiftUI

struct MapRootView: View {
    @ObservedObject var viewModel: AnyPOIMapViewModel
    @EnvironmentObject var router: MapRouter

    var body: some View {
        MapViewRepresentable(annotations: viewModel.annotations) { anno in
            router.goDetail(anno.poi)
        }
        .ignoresSafeArea()
    }
}
