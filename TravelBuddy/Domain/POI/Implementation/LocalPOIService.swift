//
//  LocalPOIService.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/28/25.
//

import Foundation
import Combine

public final class LocalPOIService: POIServiceProtocol {
    private let jsonName: String

    public init(jsonName: String = "mock_pois_local") {
        self.jsonName = jsonName
    }

    public func fetchPOIs() -> AnyPublisher<[POI], Error> {
        Deferred {
            Future<[POI], Error> { promise in
                DispatchQueue.global(qos: .background).async {
                    do {
                        guard let url = Bundle.main.url(forResource: self.jsonName, withExtension: "json") else {
                            promise(.failure(URLError(.fileDoesNotExist)))
                            return
                        }
                        let data = try Data(contentsOf: url)
                        let pois = try JSONDecoder().decode([POI].self, from: data)
                        // Имитация задержки (например, 1 секунда)
                        Thread.sleep(forTimeInterval: 1)
                        promise(.success(pois))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .receive(on: DispatchQueue.main) // результат вернётся на главный поток, удобно для ViewModel/UI
        .eraseToAnyPublisher()
    }
}
