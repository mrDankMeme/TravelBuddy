//
//  RemotePOIService.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/28/25.
//

import Foundation
import Combine

public final class RemotePOIService: POIServiceProtocol {
    private let httpClient: HTTPClientProtocol
    private let baseURL: URL

    public init(httpClient: HTTPClientProtocol, config: AppConfig) {
        self.httpClient = httpClient
        self.baseURL = config.apiBaseURL
    }

    public func fetchPOIs() -> AnyPublisher<[POI], Error> {
        let url = baseURL.appendingPathComponent("pois")
        return httpClient.send(URLRequest(url: url))
    }
}
