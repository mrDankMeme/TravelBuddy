//
//  POI.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/20/25.
//

import Foundation

public struct POI: Identifiable, Decodable, Hashable {
    public let id: Int
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let category: String?
    public let description: String?
    public let imageURL: URL?
}
