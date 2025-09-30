//
//  POIDetailCoordinator.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/11/25.
//


import SwiftUI
import Combine
import Swinject

@MainActor
public final class POIDetailCoordinator: ObservableObject {
    @Published private(set) var sheetRoute: POIDetailRoute?
    @Published private(set) var model: POIDetailModel

    private let viewModel: POIDetailViewModel
    private let router: POIDetailRouter
    private var cancellables = Set<AnyCancellable>()

    // UI error state
    @Published private var failAlert: FailAlert?
    private struct FailAlert: Identifiable { let id = UUID(); let message: String }

    public init(poi: POI, resolver: Resolver? = nil) {
        let r = resolver ?? DIContainer.shared.resolver
        guard let vm = r.resolve(POIDetailViewModel.self, argument: poi) else {
            preconditionFailure("Swinject: POIDetailViewModel не зарегистрирован для \(POI.self)")
        }

        self.viewModel = vm
        self.router    = POIDetailRouter(viewModel: vm)
        self.model     = vm.model

        router.routes
            .sink { [weak self] route in
                switch route {
                case .share(let url):       self?.sheetRoute = .share(url)
                case .openInMaps(let item): item.openInMaps(launchOptions: nil)
                case .close:                self?.sheetRoute = nil
                }
            }
            .store(in: &cancellables)

        // централизованный показ ошибок
        router.uiErrors
            .sink { [weak self] uiError in
                self?.failAlert = .init(message: uiError.localizedMessage)
            }
            .store(in: &cancellables)

        vm.modelPublisher
            .sink { [weak self] newModel in self?.model = newModel }
            .store(in: &cancellables)
    }

    @ViewBuilder
    public func rootView() -> some View {
        let binding = Binding<POIDetailRoute?>(
            get: { self.sheetRoute },
            set: { self.sheetRoute = $0 }
        )
        POIDetailView(viewModel: viewModel, sheetRoute: binding)
            .alert(item: Binding(
                get: { self.failAlert },
                set: { _ in self.failAlert = nil }
            )) { alert in
                Alert(
                    title: Text(L10n.alertErrorTitle),
                    message: Text(alert.message),
                    dismissButton: .default(Text(L10n.alertOk))
                )
            }
    }
}
