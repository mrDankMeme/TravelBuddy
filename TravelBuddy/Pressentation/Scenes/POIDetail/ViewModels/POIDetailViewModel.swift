//
//  POIDetailViewModelProtocol.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/11/25.
//


import Combine
import MapKit

public protocol POIDetailViewModelProtocol: AnyObject {
  // Outputs
  var model: POIDetailModel { get }
  var isLoadingAddress: Bool { get }
  var address: String? { get }
  var errorMessage: String? { get }

  // User actions
  func onAppear()
  func didTapShare()
  func didTapOpenInMaps()
  func didTapClose()

  // Publishers for Coordinator/Router
  var sharePublisher: AnyPublisher<URL, Never> { get }
  var openInMapsPublisher: AnyPublisher<MKMapItem, Never> { get }
  var closePublisher: AnyPublisher<Void, Never> { get }

  // Publisher for model updates
  var modelPublisher: AnyPublisher<POIDetailModel, Never> { get }
}

@MainActor
public final class POIDetailViewModel: ObservableObject, POIDetailViewModelProtocol {
  @Published public private(set) var model: POIDetailModel
  @Published public private(set) var isLoadingAddress = false
  @Published public private(set) var address: String?
  @Published public private(set) var errorMessage: String?

  private let geocoder = CLGeocoder()
  private var cancellables = Set<AnyCancellable>()

  public init(poi: POI) {
    self.model = POIDetailModel(poi: poi,
                                address: nil,
                                imageData: nil)
  }

  public func onAppear() {
    guard address == nil else { return }
    isLoadingAddress = true
    let loc = CLLocation(latitude: model.poi.latitude,
                         longitude: model.poi.longitude)
    geocoder.reverseGeocodeLocation(loc) { [weak self] places, error in
      DispatchQueue.main.async {
        self?.isLoadingAddress = false
        if let err = error {
          self?.errorMessage = err.localizedDescription
        } else {
          self?.address = places?.first?.compactAddress
        }
      }
    }
  }

  public func didTapShare() {
    let p = model.poi
    let url = URL(string: "https://maps.apple.com/?ll=\(p.latitude),\(p.longitude)")!
    shareSubject.send(url)
  }

  public func didTapOpenInMaps() {
    let p = model.poi
    let coord = CLLocationCoordinate2D(latitude: p.latitude,
                                       longitude: p.longitude)
    let item = MKMapItem(placemark: MKPlacemark(coordinate: coord))
    item.name = p.name
    openInMapsSubject.send(item)
  }

  public func didTapClose() {
    closeSubject.send(())
  }

  // Internal subjects
  private let shareSubject      = PassthroughSubject<URL, Never>()
  private let openInMapsSubject = PassthroughSubject<MKMapItem, Never>()
  private let closeSubject      = PassthroughSubject<Void, Never>()

  // Protocol publishers
  public var sharePublisher: AnyPublisher<URL, Never> {
    shareSubject.eraseToAnyPublisher()
  }
  public var openInMapsPublisher: AnyPublisher<MKMapItem, Never> {
    openInMapsSubject.eraseToAnyPublisher()
  }
  public var closePublisher: AnyPublisher<Void, Never> {
    closeSubject.eraseToAnyPublisher()
  }

  public var modelPublisher: AnyPublisher<POIDetailModel, Never> {
    $model.eraseToAnyPublisher()
  }
}

private extension CLPlacemark {
  var compactAddress: String {
    [subThoroughfare, thoroughfare, locality, administrativeArea]
      .compactMap { $0 }
      .joined(separator: ", ")
  }
}
