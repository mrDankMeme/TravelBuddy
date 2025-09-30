//
//  POIListContainer.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 9/11/25.
//



import SwiftUI
import Combine

struct POIListContainer: View {
    @State private var path = NavigationPath()
    @StateObject private var vm: AnyPOIListViewModel
    @StateObject private var router: POIListRouter
    private let makeDetail: (POI) -> AnyView

    // единый алерт
    @State private var failAlert: FailAlert?
    private struct FailAlert: Identifiable { let id = UUID(); let message: String }

    private var bag = Set<AnyCancellable>() // не @State — но нам хватит onAppear/Disappear

    init(vm: AnyPOIListViewModel, router: POIListRouter, makeDetail: @escaping (POI) -> AnyView) {
        _vm = StateObject(wrappedValue: vm)
        _router = StateObject(wrappedValue: router)
        self.makeDetail = makeDetail
    }

    var body: some View {
        NavigationStack(path: $path) {
            POIListView(viewModel: vm)
                .navigationDestination(for: POIListRoute.self) { route in
                    switch route {
                    case .detail(let poi):
                        makeDetail(poi)
                    }
                }
        }
        .onReceive(router.routes) { cmd in
            switch cmd {
            case .detail(let poi): path.append(POIListRoute.detail(poi))
            case .back: if !path.isEmpty { path.removeLast() }
            case .reset: if !path.isEmpty { path.removeLast(path.count) }
            case .showError(let e):
                failAlert = .init(message: e.localizedMessage)
            }
        }
        .onAppear {
            // Транслируем VM.errorMessage -> роутер
            vm.$errorMessage
                .compactMap { $0 }
                .sink { msg in router.showError(.plain(msg)) }
                .store(in: &router.cancellables)
        }
        .alert(item: $failAlert) { alert in
            Alert(
                title: Text(L10n.alertErrorTitle),
                message: Text(alert.message),
                dismissButton: .default(Text(L10n.alertOk))
            )
        }
        .environmentObject(router)
    }
}
