//
//  POICategoryFilter.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/1/25.
//


import Foundation

public enum POICategoryFilter: String, CaseIterable, Identifiable {
    case all = "All", monument = "Monument", museum = "Museum", cafe = "Cafe"
    public var id: String { rawValue }
}

public extension POICategoryFilter {
    var localizedTitle: String {
        switch self {
        case .all: return L10n.catAll
        case .monument: return L10n.catMonument
        case .museum: return L10n.catMuseum
        case .cafe: return L10n.catCafe
        }
    }
}
