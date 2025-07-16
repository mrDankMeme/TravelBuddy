//
//  MapCoordinator.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/10/25.
//


import SwiftUI
import Combine

@MainActor
final class MapCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    private let viewModel: AnyPOIMapViewModel
    private let router: MapRouter
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: AnyPOIMapViewModel, router: MapRouter) {
        self.viewModel = viewModel
        self.router = router
        bindRoutes()
    }

    @ViewBuilder
    func rootView() -> some View {
        // ✅ Создаём вручную Binding<NavigationPath>
        let pathBinding = Binding<NavigationPath>(
            get: { self.path },
            set: { self.path = $0 }
        )

        let snippetBinding = Binding<POI?>(
            get: { self.viewModel.selectedPOI },
            set: { self.viewModel.selectedPOI = $0 }
        )

        NavigationStack(path: pathBinding) {  // <-- тут используем именно pathBinding!
            POIMapView(viewModel: viewModel)
           
        }
        .navigationDestination(for: MapRoute.self) { route in
            switch route {
            case .detail(let poi):
                let detailCoordinator: POIDetailCoordinator =
                    DIContainer.shared.resolve(
                        POIDetailCoordinator.self,
                        argument: poi
                    )
                detailCoordinator.rootView()
            }
        }
        .sheet(item: snippetBinding) { poi in
            POISnippetView(poi: poi)
                .presentationDetents([.height(220), .medium])
                .presentationDragIndicator(.visible)
        }
        .environmentObject(router)
    }

    private func bindRoutes() {
        router.routes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] command in
                guard let self = self else { return }
                switch command {
                case .detail(let poi):
                    print("✅ Append detail route to path: \(poi)")
                    self.path.append(MapRoute.detail(poi))
                case .back:
                    if !self.path.isEmpty { self.path.removeLast() }
                case .reset:
                    self.path.removeLast(self.path.count)
                }
            }
            .store(in: &cancellables)
    }
}
