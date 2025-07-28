//
//  POIAnnotation.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/7/25.
//


import MapKit

/// Простая обёртка над POI, чтобы стать MKAnnotation
public final class POIAnnotation: NSObject, MKAnnotation {
    let poi: POI

    // локально собираем координату, модель POI не меняем
    public var coordinate: CLLocationCoordinate2D {
        .init(latitude: poi.latitude, longitude: poi.longitude)
    }

    public var title: String?    { poi.name      }
    public var subtitle: String? { poi.category  }

    init(poi: POI) { self.poi = poi }
}

/// SRP-фабрика для тестов и явной зависимости
protocol AnnotationFactory {
    func makeAnnotations(from pois: [POI]) -> [POIAnnotation]
}

struct DefaultAnnotationFactory: AnnotationFactory {
    func makeAnnotations(from pois: [POI]) -> [POIAnnotation] {
        pois.map(POIAnnotation.init)
    }
}
