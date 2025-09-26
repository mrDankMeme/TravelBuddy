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
    case invalidScheme(String?)
    case unknownHost(String?)
    case invalidQuery(String)   
    case malformed

    public var userMessage: String {
        switch self {
        case .invalidScheme:
            return "Unsupported URL scheme. Use travelbuddy://"
        case .unknownHost(let h):
            return "Unknown deeplink host \(h.map { "'\($0)'" } ?? "")."
        case .invalidQuery(let part):
            return "Invalid deeplink parameters: \(part)."
        case .malformed:
            return "Malformed deeplink URL."
        }
    }
}

public struct DeepLinkParser {
    public init() {}

    public func parse(url: URL) -> Result<DeepLink, DeepLinkError> {
        guard url.scheme?.lowercased() == "travelbuddy" else {
            return .failure(.invalidScheme(url.scheme))
        }
        switch url.host?.lowercased() {
        case "map":
            guard
                let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let latStr = comps.queryItems?.first(where: { $0.name == "lat" })?.value,
                let lonStr = comps.queryItems?.first(where: { $0.name == "lon" })?.value,
                let lat = Double(latStr), let lon = Double(lonStr)
            else { return .failure(.invalidQuery("lat/lon")) }
            return .success(.mapCenter(.init(latitude: lat, longitude: lon)))

        case "poi":
            guard let id = Int(url.lastPathComponent) else {
                return .failure(.invalidQuery("poi id"))
            }
            return .success(.poi(id: id))

        case .none:
            return .failure(.malformed)

        default:
            return .failure(.unknownHost(url.host))
        }
    }
}
