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


