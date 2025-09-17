//
//  POIListRoute.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/10/25.
//


import SwiftUI

@MainActor
final class POIListCoordinator {
    private let viewModel: AnyPOIListViewModel
    private let router: POIListRouter

    init(viewModel: AnyPOIListViewModel, router: POIListRouter) {
        self.viewModel = viewModel
        self.router = router
    }

    @ViewBuilder
    func rootView() -> some View {
        POIListContainer(vm: viewModel, router: router)
    }
}
