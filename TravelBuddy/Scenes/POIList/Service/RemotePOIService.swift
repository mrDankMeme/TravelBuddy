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
    private let endpoint = URL(string: "https://api.example.com/pois")!

    public init(httpClient: HTTPClientProtocol) {
        self.httpClient = httpClient
    }

    public func fetchPOIs() -> AnyPublisher<[POI], Error> {
        httpClient.send(URLRequest(url: endpoint))
    }

}
