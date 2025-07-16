//
//  POIServiceProtocol.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/11/25.
//


import Foundation
import Combine

public protocol POIServiceProtocol {
  func fetchPOIs() -> AnyPublisher<[POI], Error>
}