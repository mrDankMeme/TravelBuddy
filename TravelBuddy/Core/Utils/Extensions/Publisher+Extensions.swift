//
//  Publisher+Extensions.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/20/25.
//

import Combine

public extension Publisher {
  func logError(_ tag: String) -> AnyPublisher<Output, Failure> {
    handleEvents(receiveCompletion: { completion in
      if case let .failure(error) = completion {
          Swift.print("[\(tag)] Error:", error)
      }
    })
    .eraseToAnyPublisher()
  }
}
