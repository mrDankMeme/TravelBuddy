//
//  POIListRoute.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/10/25.
//



import SwiftUI
import Combine

@MainActor
final class POIListCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    private let viewModel: AnyPOIListViewModel
    private let router: POIListRouter
    
    // Храним здесь все наши cancellables
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: AnyPOIListViewModel,
         router: POIListRouter) {
        self.viewModel = viewModel
        self.router = router
        bindRoutes()
    }
    
    @ViewBuilder
    func rootView() -> some View {
        let bindingPath = Binding<NavigationPath>(
            get: { self.path },
            set: { self.path = $0 }
        )
        
        NavigationStack(path: bindingPath) {
            POIListView(viewModel: viewModel)
                .navigationDestination(for: POIListRoute.self) { route in
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
                    self.path.append( POIListRoute.detail(poi) )
                case .back:
                    if !self.path.isEmpty {
                        self.path.removeLast()
                    }
                case .reset:
                    self.path.removeLast(self.path.count)
                }
            }
            .store(in: &cancellables)
    }
}
