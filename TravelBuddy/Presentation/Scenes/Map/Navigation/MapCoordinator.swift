//
//  MapCoordinator.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/10/25.
//


import SwiftUI
import Combine

@MainActor
final class MapCoordinator {
    private let vm: AnyPOIMapViewModel
    private let router: MapRouter
    
    init(vm: AnyPOIMapViewModel, router: MapRouter) {
        self.vm     = vm
        self.router = router
    }
    
    /// Отдаём единственный корневой view
    func rootView() -> some View {
        MapContainer(vm: vm, router: router)
    }
}

