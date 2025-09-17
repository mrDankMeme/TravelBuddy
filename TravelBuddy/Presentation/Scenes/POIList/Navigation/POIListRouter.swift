//
//  POIListRoute.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/11/25.
//


import SwiftUI
import Combine

enum POIListRoute: Hashable {
    case detail(POI)
}

enum POIListNavigationCommand {
    case detail(POI)
    case back
    case reset
}

@MainActor
final class POIListRouter: ObservableObject {
    let routes = PassthroughSubject<POIListNavigationCommand, Never>()
    fileprivate var cancellables = Set<AnyCancellable>()
    
    func goDetail(_ poi: POI){
        routes.send(.detail(poi))
    }
    func goBack(){
        routes.send(.back)
    }
    func reset(){
        routes.send(.reset)
    }
}
