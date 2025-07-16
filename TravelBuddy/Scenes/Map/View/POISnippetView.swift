//
//  POISnippetView.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/7/25.
//



import SwiftUI
import MapKit

struct POISnippetView: View {
    let poi: POI
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(poi.name).font(.title2).bold()
            if let cat = poi.category { Text(cat).foregroundColor(.secondary) }
            if let desc = poi.description { Text(desc).lineLimit(3) }

            HStack {
                Button("Details") {
                    NotificationCenter.default.post(name: .openPOIDetail, object: poi)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

                Spacer()
                Button("Route") {
                    let coord = CLLocationCoordinate2D(latitude: poi.latitude,
                                                        longitude: poi.longitude)
                    MKMapItem(placemark: MKPlacemark(coordinate: coord))
                        .openInMaps()
                }
            }
        }
        .padding()
    }
}

extension Notification.Name {
    static let openPOIDetail = Notification.Name("openPOIDetail")
}
