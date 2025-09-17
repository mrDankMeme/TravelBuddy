//
//  POIDetailRoute.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/11/25.
//


import Combine
import MapKit

public enum POIDetailRoute: Hashable, Identifiable {
  case share(URL)
  case openInMaps(MKMapItem)
  case close

  public var id: String {
    switch self {
    case .share(let url):
      return "share:\(url.absoluteString)"
    case .openInMaps(let item):
      let c = item.placemark.coordinate
      return "open:\(c.latitude),\(c.longitude)"
    case .close:
      return "close"
    }
  }
}

@MainActor
public final class POIDetailRouter: ObservableObject {
  public let routes = PassthroughSubject<POIDetailRoute, Never>()
  private var cancellables = Set<AnyCancellable>()

  public init(viewModel: POIDetailViewModel) {
    // мы теперь используем конкретную ViewModel
    viewModel.sharePublisher
      .map(POIDetailRoute.share)
      .sink { [routes] in routes.send($0) }
      .store(in: &cancellables)

    viewModel.openInMapsPublisher
      .map(POIDetailRoute.openInMaps)
      .sink { [routes] in routes.send($0) }
      .store(in: &cancellables)

    viewModel.closePublisher
      .map { _ in POIDetailRoute.close }
      .sink { [routes] in routes.send($0) }
      .store(in: &cancellables)
  }
}
