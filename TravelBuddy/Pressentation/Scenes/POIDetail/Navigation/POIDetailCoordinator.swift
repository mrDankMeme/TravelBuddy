//
//  POIDetailCoordinator.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/11/25.
//


import SwiftUI
import Combine


@MainActor
public final class POIDetailCoordinator: ObservableObject {
  @Published private(set) var sheetRoute: POIDetailRoute?
  @Published private(set) var model: POIDetailModel

  private let viewModel: POIDetailViewModel
  private let router: POIDetailRouter
  private var cancellables = Set<AnyCancellable>()

  public init(poi: POI) {
    // Получаем ***конкретную*** ViewModel
    let vm: POIDetailViewModel = DIContainer.shared
      .resolve(POIDetailViewModel.self, argument: poi)

    self.viewModel = vm
    self.router    = POIDetailRouter(viewModel: vm)
    self.model     = vm.model

    // Навигация
    router.routes
      .sink { [weak self] route in
        switch route {
        case .share(let url):       self?.sheetRoute = .share(url)
        case .openInMaps(let item): item.openInMaps(launchOptions: nil)
        case .close:                self?.sheetRoute = nil
        }
      }
      .store(in: &cancellables)

    // Синхронизация модели
    vm.modelPublisher
      .sink { [weak self] newModel in
        self?.model = newModel
      }
      .store(in: &cancellables)
  }

  @ViewBuilder
  public func rootView() -> some View {
    let binding = Binding<POIDetailRoute?>(
        get: { self.sheetRoute },
        set: { self.sheetRoute = $0 }
    )
    // Передаём конкретную VM
    POIDetailView(
      viewModel: viewModel,
      sheetRoute: binding
    )
  }
}
