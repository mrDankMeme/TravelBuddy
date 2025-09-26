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
    var errorEvents: AnyPublisher<DeepLinkError, Never> { get }  // NEW
}

public final class DeepLinkService: DeepLinkHandling {
    private let parser = DeepLinkParser()

    private let subject = CurrentValueSubject<DeepLink?, Never>(nil)
    private let errorSubject = CurrentValueSubject<DeepLinkError?, Never>(nil) // NEW

    public init() {}

    public func handle(url: URL) {
        switch parser.parse(url: url) {
        case .success(let dl):
            subject.value = dl
        case .failure(let err):
            errorSubject.value = err
        }
    }

    public var events: AnyPublisher<DeepLink, Never> {
        subject.compactMap { $0 }.eraseToAnyPublisher()
    }

    public var errorEvents: AnyPublisher<DeepLinkError, Never> {
        errorSubject.compactMap { $0 }.eraseToAnyPublisher()
    }
}
