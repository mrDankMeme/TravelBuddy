//
//  POIRepository.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/1/25.
//


import Combine
import Foundation

public final class POIRepository: POIServiceProtocol {
    private let remote: POIServiceProtocol
    private let local: POIServiceProtocol
    private let cache: POICacheProtocol

    public init(remote: POIServiceProtocol,
                local: POIServiceProtocol,
                cache: POICacheProtocol) {
        self.remote = remote
        self.local = local
        self.cache = cache
    }

    public func fetchPOIs() -> AnyPublisher<[POI], Error> {
        
        let cachePublisher = Just(cache.load())
            .setFailureType(to: Error.self)

        let remotePublisher = remote.fetchPOIs()
            .handleEvents(receiveOutput: { [weak cache] pois in
                cache?.save(pois)
            })
            .catch { [weak self] _ -> AnyPublisher<[POI], Error> in
                
                guard let self = self else {
                    return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
                }
                return self.local.fetchPOIs()
                    .handleEvents(receiveOutput: { [weak cache] pois in cache?.save(pois) })
                    .eraseToAnyPublisher()
            }

        
        return cachePublisher
            .append(remotePublisher)
            .eraseToAnyPublisher()
    }
}
