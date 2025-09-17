//
//  RealmPOICache.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/30/25.
//

import Foundation
import RealmSwift

public final class RealmPOICache: POICacheProtocol {
    public func save(_ pois: [POI]) {
        autoreleasepool {
            do {
                let realm = try Realm()
                let objects = pois.map { RealmPOI(poi: $0) }
                try realm.write { realm.add(objects, update: .modified) }
            } catch { /* лог при желании */ }
        }
    }

    public func load() -> [POI] {
        autoreleasepool {
            (try? Realm()).map { Array($0.objects(RealmPOI.self)).map { $0.toPOI() } } ?? []
        }
    }
}

public final class RealmPOI: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    @objc dynamic var category: String? = nil
    @objc dynamic var descriptionText: String? = nil
    @objc dynamic var imageURLString: String? = nil

    public override static func primaryKey() -> String? { "id" }

    convenience init(poi: POI) {
        self.init()
        id = poi.id; name = poi.name
        latitude = poi.latitude; longitude = poi.longitude
        category = poi.category
        descriptionText = poi.description
        imageURLString = poi.imageURL?.absoluteString
    }

    func toPOI() -> POI {
        POI(
          id: id, name: name,
          latitude: latitude, longitude: longitude,
          category: category,
          description: descriptionText,
          imageURL: imageURLString.flatMap(URL.init)
        )
    }
}

