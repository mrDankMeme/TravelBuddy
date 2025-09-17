//
//  AnyPOIMapViewModel.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/7/25.
//


import Combine
import SwiftUI

public final class AnyPOIMapViewModel: ObservableObject {
    // -------- SwiftUI bindings --------
    @Published public var annotations: [POIAnnotation] = []
    @Published public var selectedPOI: POI?            = nil

    // -------- Internals --------
    private let wrapped: any POIMapViewModelProtocol
    private var bag = Set<AnyCancellable>()

    // MARK: – init
    public init(_ wrapped: any POIMapViewModelProtocol) {
        self.wrapped      = wrapped
        self.annotations  = wrapped.annotations
        self.selectedPOI  = wrapped.selectedPOI

        // Если это именно POIMapViewModel, подписываемся на его @Published-поля
        if let concrete = wrapped as? POIMapViewModel {
            concrete.$annotations
                .receive(on: DispatchQueue.main)
                .assign(to: &$annotations)

            concrete.$selectedPOI
                .receive(on: DispatchQueue.main)
                .assign(to: &$selectedPOI)
        }
    }

    // MARK: – Facade
    public func fetch()                           { wrapped.fetch() }
    public func select(annotation: POIAnnotation) { wrapped.select(annotation: annotation) }
}
