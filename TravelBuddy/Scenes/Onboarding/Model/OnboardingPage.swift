//
//  OnboardingPage.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/26/25.
//


import Foundation

public struct OnboardingPage: Identifiable {
  public let id: Int
  public let imageName: String
  public let title: String
  public let description: String

  public init(
    id: Int,
    imageName: String,
    title: String,
    description: String
  ) {
    self.id = id
    self.imageName = imageName
    self.title = title
    self.description = description
  }
}
