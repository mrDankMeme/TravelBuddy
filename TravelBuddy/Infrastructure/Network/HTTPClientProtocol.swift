//
//  HTTPClient.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/20/25.
//


import Foundation
import Combine

public protocol HTTPClientProtocol {
  func send<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error>
}

