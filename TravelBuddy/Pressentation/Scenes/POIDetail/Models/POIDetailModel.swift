//
//  POIDetailModel.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/11/25.
//


import Foundation

public struct POIDetailModel {
  public let poi: POI
  public let address: String?
  public let imageData: Data?

  public init(
    poi: POI,
    address: String?,
    imageData: Data?
  ) {
    self.poi = poi
    self.address = address
    self.imageData = imageData
  }
}
