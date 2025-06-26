//
//  POIListViewModel.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/20/25.
//


import Combine


public protocol POIListViewModelProtocol {
  // MARK: – Outputs: то, на что подписывается ViewController
  var poisPublisher: AnyPublisher<[POI], Never> { get }
  var errorPublisher: AnyPublisher<String?, Never> { get }

  // MARK: – Inputs: команды от ViewController
  func refresh()
}

public final class POIListViewModel: POIListViewModelProtocol {
  // MARK: – Internal storage
  @Published private var pois: [POI] = []
  @Published private var error: String?

  // MARK: – Публичные паблишеры
  public var poisPublisher: AnyPublisher<[POI], Never> {
    $pois.eraseToAnyPublisher()
  }
  public var errorPublisher: AnyPublisher<String?, Never> {
    $error.eraseToAnyPublisher()
  }

  // MARK: – Зависимости
  private let poiService: POIServiceProtocol
  private let analytics: AnalyticsServiceProtocol
  private let notification: NotificationServiceProtocol
  private var cancellables = Set<AnyCancellable>()

  public init(poiService: POIServiceProtocol,
              analytics: AnalyticsServiceProtocol,
              notification: NotificationServiceProtocol) {
    self.poiService    = poiService
    self.analytics     = analytics
    self.notification  = notification
  }

  // MARK: – Input
  public func refresh() {
    poiService.fetchPOIs()
      .sink { completion in
        if case let .failure(err) = completion {
          self.error = err.localizedDescription
          self.analytics.recordError(err)
        }
      } receiveValue: { pois in
        self.pois = pois
        self.analytics.logEvent(
          name: "LoadedPOIs",
          parameters: ["count": pois.count]
        )
      }
      .store(in: &cancellables)
  }
}
