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
    
    public init(config: AppConfig) {
        self.jsonName = config.localPOIJSONName
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
                        //Thread.sleep(forTimeInterval: 0)
                        promise(.success(pois))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
