//
//  POIListContainer.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 9/11/25.
//


import SwiftUI
import Combine

/// Обёртка сцены списка:
/// — владеет NavigationPath,
/// — слушает POIListRouter и применяет команды к $path,
/// — лениво резолвит координатор деталки.
struct POIListContainer: View {
    @State private var path = NavigationPath()
    @StateObject private var vm: AnyPOIListViewModel
    @StateObject private var router: POIListRouter

    init(vm: AnyPOIListViewModel, router: POIListRouter) {
        _vm = StateObject(wrappedValue: vm)
        _router = StateObject(wrappedValue: router)
    }

    var body: some View {
        NavigationStack(path: $path) {
            POIListView(viewModel: vm)
                .navigationDestination(for: POIListRoute.self) { route in
                    switch route {
                    case .detail(let poi):
                        DIContainer.shared.resolver
                            .resolve(POIDetailCoordinator.self, argument: poi)!
                            .rootView()
                    }
                }
        }
        .onReceive(router.routes) { cmd in
            switch cmd {
            case .detail(let poi): path.append(POIListRoute.detail(poi))
            case .back: if !path.isEmpty { path.removeLast() }
            case .reset: if !path.isEmpty { path.removeLast(path.count) }
            }
        }
        .environmentObject(router)
    }
}
