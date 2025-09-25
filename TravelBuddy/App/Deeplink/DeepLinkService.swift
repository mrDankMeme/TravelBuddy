//
//  DeepLinkService.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/7/25.
//

import Foundation
import CoreLocation
import Combine

public protocol DeepLinkHandling {
    func handle(url: URL)
    var events: AnyPublisher<DeepLink, Never> { get }
}

public final class DeepLinkService: DeepLinkHandling {
    private let parser = DeepLinkParser()

    // было: private let subject = PassthroughSubject<DeepLink, Never>()
    private let subject = CurrentValueSubject<DeepLink?, Never>(nil)

    public init() {}

    public func handle(url: URL) {
        guard let dl = parser.parse(url: url) else { return }
        subject.value = dl
    }

    public var events: AnyPublisher<DeepLink, Never> {
        subject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
