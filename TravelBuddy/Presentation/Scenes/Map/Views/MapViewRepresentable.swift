//
//  MapViewRepresentable.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/7/25.
//


// Presentation/Scenes/Map/Views/MapViewRepresentable.swift
import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    let annotations: [POIAnnotation]
    let defaultRegionMeters: CLLocationDistance

    // ✅ Новый единый источник правды для выделения
    @Binding var selectedId: Int?

    // (оставим коллбек для совместимости; передадим noop)
    let onSelect: (POIAnnotation) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "marker")
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "cluster")
        map.showsUserLocation = true
        map.pointOfInterestFilter = .excludingAll
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        // --- дифф аннотаций (как у тебя было) ---
        let existing = map.annotations.compactMap { $0 as? POIAnnotation }
        let existingIDs = Set(existing.map { $0.poi.id })
        let incomingIDs = Set(annotations.map { $0.poi.id })

        let toRemove = existing.filter { !incomingIDs.contains($0.poi.id) }
        if !toRemove.isEmpty { map.removeAnnotations(toRemove) }

        let toAdd = annotations.filter { !existingIDs.contains($0.poi.id) }
        if !toAdd.isEmpty { map.addAnnotations(toAdd) }

        // --- первичная установка региона (как у тебя было) ---
        if !context.coordinator.hasSetInitialRegion, !map.annotations.isEmpty {
            context.coordinator.hasSetInitialRegion = true
            let poiAnnos = map.annotations.compactMap { $0 as? POIAnnotation }
            if poiAnnos.count == 1, let only = poiAnnos.first {
                let region = MKCoordinateRegion(
                    center: only.coordinate,
                    latitudinalMeters: defaultRegionMeters,
                    longitudinalMeters: defaultRegionMeters
                )
                map.setRegion(region, animated: false)
            } else {
                map.showAnnotations(poiAnnos, animated: false)
                let insets = UIEdgeInsets(top: 80, left: 40, bottom: 160, right: 40)
                map.setVisibleMapRect(map.visibleMapRect, edgePadding: insets, animated: false)
            }
        }

        // --- 🔑 синхронизация выделения ---
        if let id = selectedId {
            // выбрать соответствующую аннотацию, если ещё не выбрана
            if let anno = map.annotations.compactMap({ $0 as? POIAnnotation }).first(where: { $0.poi.id == id }) {
                let already = map.selectedAnnotations.contains {
                    guard let a = $0 as? POIAnnotation else { return false }
                    return a.poi.id == id
                }
                if !already { map.selectAnnotation(anno, animated: true) }
            }
        } else {
            // снять выделение, если что-то выбрано
            if !map.selectedAnnotations.isEmpty {
                map.selectedAnnotations.forEach { map.deselectAnnotation($0, animated: true) }
            }
        }
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var hasSetInitialRegion = false
        let parent: MapViewRepresentable
        private var lastSelectedId: Int?

        init(_ parent: MapViewRepresentable) { self.parent = parent }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let anno = view.annotation as? POIAnnotation else { return }
            // анти-дубль от MKMapView
            guard lastSelectedId != anno.poi.id else { return }
            lastSelectedId = anno.poi.id

            // обновляем биндинг (вверх по иерархии)
            parent.selectedId = anno.poi.id

            // совместимость: если снаружи что-то ещё слушают
            parent.onSelect(anno)
        }

        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            guard let anno = view.annotation as? POIAnnotation else { return }
            if lastSelectedId == anno.poi.id { lastSelectedId = nil }
            if parent.selectedId == anno.poi.id { parent.selectedId = nil }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let cluster = annotation as? MKClusterAnnotation {
                let v = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster", for: annotation) as! MKMarkerAnnotationView
                v.displayPriority = .required
                v.markerTintColor = .systemBlue
                v.glyphText = "\(cluster.memberAnnotations.count)"
                v.titleVisibility = .hidden
                v.subtitleVisibility = .hidden
                v.canShowCallout = false
                return v
            }
            guard annotation is POIAnnotation else { return nil }
            let v = mapView.dequeueReusableAnnotationView(withIdentifier: "marker", for: annotation) as! MKMarkerAnnotationView
            v.displayPriority      = .defaultHigh
            v.clusteringIdentifier = "poi"
            v.markerTintColor      = .systemBlue
            v.glyphImage           = UIImage(systemName: "mappin")
            v.canShowCallout       = false
            return v
        }
    }
}
