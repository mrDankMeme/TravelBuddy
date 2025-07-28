//
//  AnyPOIListViewModel.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/1/25.
//

import Foundation
import Combine

public final class AnyPOIListViewModel: ObservableObject {
    @Published public var filter: POICategoryFilter = .all
    @Published public var pois: [POI] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil

    private let wrapped: POIListViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    public init(_ wrapped: POIListViewModelProtocol) {
        self.wrapped = wrapped
        self.filter = wrapped.filter

        // 1. Пробрасываем filter из wrapper в wrapped
        $filter
            .dropFirst()
            .sink { [weak self] newFilter in
                guard let self else { return }
                if self.wrapped.filter != newFilter {
                    self.wrapped.filter = newFilter
                }
            }
            .store(in: &cancellables)

        // 2. Пробрасываем filter из wrapped наружу (если вдруг он меняется)
        if let vm = wrapped as? POIListViewModel {
            vm.$filter
                .receive(on: DispatchQueue.main)
                .sink { [weak self] newFilter in
                    guard let self else { return }
                    if self.filter != newFilter {
                        self.filter = newFilter
                    }
                }
                .store(in: &cancellables)

            vm.$pois
                .receive(on: DispatchQueue.main)
                .assign(to: &$pois)
            vm.$isLoading
                .receive(on: DispatchQueue.main)
                .assign(to: &$isLoading)
            vm.$errorMessage
                .receive(on: DispatchQueue.main)
                .assign(to: &$errorMessage)
        }
    }

    public func fetchPOIs() { wrapped.fetchPOIs() }
    public func openInMaps(poi: POI) { wrapped.openInMaps(poi: poi) }
}
