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
    var onDetails: () -> Void
    var onRoute:   () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(poi.name).font(.title2).bold()
            if let cat = poi.category { Text(cat).foregroundColor(.secondary) }
            if let desc = poi.description { Text(desc).lineLimit(3) }

            HStack {
                Button("Details", action: onDetails)
                    .buttonStyle(.borderedProminent)

                Spacer()
                Button("Route", action: onRoute)
            }
        }
        .padding()
    }
}
