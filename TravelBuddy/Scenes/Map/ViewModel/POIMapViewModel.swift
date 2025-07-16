//
//  POIMapViewModelProtocol.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/7/25.
//


import Combine
import MapKit

public protocol POIMapViewModelProtocol: ObservableObject {
    var annotations: [POIAnnotation] { get }
    var selectedPOI: POI? { get }
    func fetch()
    func select(annotation: POIAnnotation)
}

public final class POIMapViewModel: POIMapViewModelProtocol {
    // Output
    @Published public private(set) var annotations: [POIAnnotation] = []
    @Published public private(set) var selectedPOI: POI?

    // Deps
    private let service: POIServiceProtocol
    private let factory: AnnotationFactory
    private var bag = Set<AnyCancellable>()

    init(service: POIServiceProtocol,
                factory: AnnotationFactory = DefaultAnnotationFactory()) {
        self.service  = service
        self.factory  = factory
    }

    public func fetch() {
        service.fetchPOIs()
            .map(factory.makeAnnotations)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] in self?.annotations = $0 })
            .store(in: &bag)
    }

    public func select(annotation: POIAnnotation) {
        selectedPOI = annotation.poi
    }
}
