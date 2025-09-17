//
//  AppRoute.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 9/12/25.
//


import Foundation

public enum AppRoute: Equatable {
    case openPOIDetail(POI)
    case openMapWithPOI(POI.ID)
    case openSettings
}
