//
//  POIListViewModel.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/20/25.
//



import Combine
import CoreLocation
import MapKit

public protocol POIListViewModelProtocol: AnyObject {
    // Inputs
    var filter: POICategoryFilter { get set }
    func fetchPOIs()
    func openInMaps(poi: POI)

    // Outputs
    var pois: [POI] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
}

public final class POIListViewModel: ObservableObject, POIListViewModelProtocol {
    // MARK: Inputs
    @Published public var filter: POICategoryFilter = .all

    // MARK: Internal state
    private var allPois: [POI] = []

    // MARK: Outputs
    @Published public private(set) var pois: [POI] = []
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var errorMessage: String? = nil

    private let repository: POIServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    public init(repository: POIServiceProtocol) {
        self.repository = repository

        // Локальная фильтрация при смене filter
        $filter
          .dropFirst()
            .sink { [weak self] newFilter in
                self?.applyFilter(using: newFilter)
            }
          .store(in: &cancellables)
    }

    public func fetchPOIs() {
        isLoading = true
        errorMessage = nil

        repository.fetchPOIs()
          .receive(on: DispatchQueue.main)
          .sink { [weak self] completion in
            guard let self = self else { return }
            self.isLoading = false
            if case let .failure(err) = completion {
                self.errorMessage = err.localizedDescription
            }
          } receiveValue: { [weak self] list in
            guard let self = self else { return }
            self.allPois = list
            self.applyFilter()
          }
          .store(in: &cancellables)
    }
    private func applyFilter() {
           if filter == .all {
               pois = allPois
           } else {
               pois = allPois.filter { $0.category == filter.rawValue }
           }
       }
    private func applyFilter(using filter: POICategoryFilter) {
        pois = (filter == .all)
             ? allPois
             : allPois.filter { $0.category == filter.rawValue }
    }


    public func openInMaps(poi: POI) {
        let coord = CLLocationCoordinate2D(latitude: poi.latitude,
                                           longitude: poi.longitude)
        let item = MKMapItem(placemark: MKPlacemark(coordinate: coord))
        item.name = poi.name
        item.openInMaps(launchOptions: nil)
    }
}
