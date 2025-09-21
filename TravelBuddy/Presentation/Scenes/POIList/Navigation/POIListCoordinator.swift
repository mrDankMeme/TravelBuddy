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
    private let makeDetail: (POI) -> AnyView
    
    init(viewModel: AnyPOIListViewModel, router: POIListRouter) {
        self.viewModel = viewModel
        self.router = router
        let resolver = DIContainer.shared.resolver
        self.makeDetail = { poi in
            guard let coord = resolver.resolve(POIDetailCoordinator.self, argument: poi) else {
                return AnyView(EmptyView())
            }
            return AnyView(coord.rootView())
        }
    }
    
    @ViewBuilder
    func rootView() -> some View {
        POIListContainer(vm: viewModel, router: router, makeDetail: makeDetail)
    }
}
