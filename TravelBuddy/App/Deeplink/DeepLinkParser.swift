//
//  DeepLinkParser.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/17/25.
//


import CoreLocation

public enum DeepLink {
    case mapCenter(CLLocationCoordinate2D)
    case poi(id: Int)
}

public enum DeepLinkError: Error {
    case unsupportedScheme
    case unknownHost
    case invalidCoordinates
}



public struct DeepLinkParser {
    public init() {}

    public func parse(url: URL) -> Result<DeepLink, DeepLinkError> {
        let scheme = url.scheme?.lowercased()
        if scheme == "travelbuddy" {
            return parseCustomScheme(url)
        }
        return .failure(.unsupportedScheme)
    }

    private func parseCustomScheme(_ url: URL) -> Result<DeepLink, DeepLinkError> {
        switch url.host?.lowercased() {
        case "map":
            return parseMap(url)
        case "poi":
            guard let id = Int(url.lastPathComponent) else {
                return .failure(.unknownHost)
            }
            return .success(.poi(id: id))
        default:
            return .failure(.unknownHost)
        }
    }

    private func parseMap(_ url: URL) -> Result<DeepLink, DeepLinkError> {
        guard
            let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let latStr = comps.queryItems?.first(where: { $0.name == "lat" })?.value,
            let lonStr = comps.queryItems?.first(where: { $0.name == "lon" })?.value,
            let lat = Double(latStr),
            let lon = Double(lonStr)
        else {
            return .failure(.invalidCoordinates)
        }
        return .success(.mapCenter(.init(latitude: lat, longitude: lon)))
    }
}
