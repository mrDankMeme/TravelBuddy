//
//  POICacheProtocol.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/28/25.
//


import Foundation

public protocol POICacheProtocol: AnyObject {
    func save(_ pois: [POI])
    func load() -> [POI]
}
