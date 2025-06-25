//
//  POIService.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/20/25.
//

import Foundation
import Combine

public protocol POIServiceProtocol {
  func fetchPOIs() -> AnyPublisher<[POI], Error>
}

public final class POIService: POIServiceProtocol {
  private let httpClient: HTTPClientProtocol
  private let baseURL = URL(string: "https://api.example.com")!

  public init(httpClient: HTTPClientProtocol) {
    self.httpClient = httpClient
  }

  public func fetchPOIs() -> AnyPublisher<[POI], Error> {
    let req = URLRequest(url: baseURL.appendingPathComponent("pois"))
    return httpClient.send(req)
      .logError("POIService")
      .eraseToAnyPublisher()
  }
}
