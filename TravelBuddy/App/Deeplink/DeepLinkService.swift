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
    var errors: AnyPublisher<DeepLinkError, Never> { get }
}

public final class DeepLinkService: DeepLinkHandling {
    private let parser = DeepLinkParser()

    private let successSubject = CurrentValueSubject<DeepLink?, Never>(nil)
    private let errorSubject = PassthroughSubject<DeepLinkError, Never>()

    public init() {}

    public func handle(url: URL) {
        switch parser.parse(url: url) {
        case .success(let dl):
            successSubject.value = dl
        case .failure(let err):
            errorSubject.send(err)
        }
    }

    public var events: AnyPublisher<DeepLink, Never> {
        successSubject.compactMap { $0 }.eraseToAnyPublisher()
    }

    public var errors: AnyPublisher<DeepLinkError, Never> {
        errorSubject.eraseToAnyPublisher()
    }
}
