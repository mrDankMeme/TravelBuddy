// Core/DeepLink/DeepLink.swift
import Foundation
import CoreLocation

public enum DeepLink {
    case mapCenter(CLLocationCoordinate2D)
    case poi(id: Int)
}

public struct DeepLinkParser {
    public init() {}

    public func parse(url: URL) -> DeepLink? {
        guard url.scheme?.lowercased() == "travelbuddy" else { return nil }
        switch url.host?.lowercased() {
        case "map":
            guard
                let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let latStr = comps.queryItems?.first(where: { $0.name == "lat" })?.value,
                let lonStr = comps.queryItems?.first(where: { $0.name == "lon" })?.value,
                let lat = Double(latStr), let lon = Double(lonStr)
            else { return nil }
            return .mapCenter(.init(latitude: lat, longitude: lon))

        case "poi":
            guard let id = Int(url.lastPathComponent) else { return nil }
            return .poi(id: id)

        default:
            return nil
        }
    }
}
