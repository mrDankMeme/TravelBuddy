//
//  POI.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/20/25.
//

import Foundation

public struct POI: Decodable, Identifiable {
  public let id: Int
  public let name: String
  public let latitude: Double
  public let longitude: Double
}
