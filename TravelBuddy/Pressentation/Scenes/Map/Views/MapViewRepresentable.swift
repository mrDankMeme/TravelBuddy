//
//  MapViewRepresentable.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/7/25.
//



import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    let annotations: [POIAnnotation]
    let onSelect: (POIAnnotation) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.register(MKMarkerAnnotationView.self,
                     forAnnotationViewWithReuseIdentifier: "marker")
        map.showsUserLocation       = true
        map.pointOfInterestFilter   = .excludingAll
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        map.removeAnnotations(map.annotations)
        map.addAnnotations(annotations)

        if let first = annotations.first {
            map.setRegion(
                .init(center: first.coordinate,
                      latitudinalMeters: 4000,
                      longitudinalMeters: 4000),
                animated: false
            )
        }
    }

    // MARK: - Coordinator
    final class Coordinator: NSObject, MKMapViewDelegate {
        let parent: MapViewRepresentable
        init(_ parent: MapViewRepresentable) { self.parent = parent }

        func mapView(_ mapView: MKMapView,
                     didSelect view: MKAnnotationView) {
            guard let anno = view.annotation as? POIAnnotation else { return }
            parent.onSelect(anno)
        }

        func mapView(_ mapView: MKMapView,
                     viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKClusterAnnotation),
                  annotation is POIAnnotation else { return nil }

            let v = mapView.dequeueReusableAnnotationView(withIdentifier: "marker",
                                                          for: annotation) as! MKMarkerAnnotationView
            v.displayPriority      = .defaultHigh
            v.clusteringIdentifier = "poi"
            v.markerTintColor      = .systemBlue
            v.glyphImage           = UIImage(systemName: "mappin")
            v.canShowCallout       = false
            return v
        }
    }
}
