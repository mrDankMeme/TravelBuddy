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
    private var didLoadRemote = false
    
    public init(remote: POIServiceProtocol,
                local: POIServiceProtocol,
                cache: POICacheProtocol) {
        self.remote = remote
        self.local = local
        self.cache = cache
    }

    public func fetchPOIs() -> AnyPublisher<[POI], Error> {
        if !didLoadRemote {
            didLoadRemote = true
            // Сначала кеш, потом remote
            let cachePublisher = Deferred {
                Future<[POI], Error> { [weak self] promise in
                    DispatchQueue.global(qos: .userInitiated).async {
                        let pois = self?.cache.load() ?? []
                        promise(.success(pois))
                    }
                }
            }
            .eraseToAnyPublisher()

            let remotePublisher = remote.fetchPOIs()
                .timeout(.seconds(0.1), scheduler: DispatchQueue.global(qos: .userInitiated))
                .handleEvents(receiveOutput: { [weak self] pois in
                    self?.cache.save(pois)
                })
                .catch { [weak self] _ -> AnyPublisher<[POI], Error> in
                    guard let self = self else {
                        return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
                    }
                    return self.local.fetchPOIs()
                        .handleEvents(receiveOutput: { [weak self] pois in self?.cache.save(pois) })
                        .eraseToAnyPublisher()
                }

            return cachePublisher
                .append(remotePublisher)
                .eraseToAnyPublisher()
        } else {
            // Только кеш
            return Deferred {
                Future<[POI], Error> { [weak self] promise in
                    DispatchQueue.global(qos: .userInitiated).async {
                        let pois = self?.cache.load() ?? []
                        promise(.success(pois))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
    }
}
