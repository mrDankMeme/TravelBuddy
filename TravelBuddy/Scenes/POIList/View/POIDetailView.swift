//
//  POIDetailView.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/1/25.
//


import SwiftUI
import MapKit

public struct POIDetailView: View {
    let poi: POI
    @ObservedObject var vm: AnyPOIListViewModel

    public init(poi: POI, viewModel: AnyPOIListViewModel) {
        self.poi = poi
        self.vm = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                POIImageView(imagePath: poi.imageURL?.path)
                        .frame(height: 200)
                        .cornerRadius(12)
                        .padding(.bottom, 8)
                Text(poi.name).font(.largeTitle).bold()
                if let desc = poi.description {
                    Text(desc).font(.body)
                }
                MapView(coordinate: .init(latitude: poi.latitude, longitude: poi.longitude))
                    .frame(height: 200)
                    .cornerRadius(12)
                Button("Open in Maps") { vm.openInMaps(poi: poi) }
                  .buttonStyle(.borderedProminent)
                Spacer()
            }
            .padding()
        }
        .navigationTitle(poi.name)
    }
}

private struct MapView: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D

    func makeUIView(context: Context) -> MKMapView { MKMapView() }
    func updateUIView(_ m: MKMapView, context: Context) {
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        m.setRegion(region, animated: false)
        m.removeAnnotations(m.annotations)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        m.addAnnotation(pin)
    }
}

