//
//  LocationPoint.swift
//  RoadTripPlanner
//
//  Created by Allen Fang, Alan Le, Harrison Mai, and Sam Moon on 5/19/17.
//  Copyright © 2017 Allen Fang, Alan Le, Harrison Mai, and Sam Moon. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

struct LocationKey {
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let radius = "radius"
    static let identifier = "identifier"
    static let note = "note"
    static let eventType = "eventType"
}

enum EventType: String {
    case onEntry = "On Entry"
    case onExit = "On Exit"
}


class LocationPoint: NSObject, NSCoding, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var note: String
    var eventType: EventType
    
    var title: String? {
        if note.isEmpty {
            return "No Note"
        }
        return note
    }
    
    var subtitle: String? {
        let eventTypeString = eventType.rawValue
        return "Radius: \(radius)m - \(eventTypeString)"
    }
    
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, note: String, eventType: EventType) {
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
        self.note = note
        self.eventType = eventType
    }
    
    // MARK: NSCoding
    required init?(coder decoder: NSCoder) {
        let latitude = decoder.decodeDouble(forKey: LocationKey.latitude)
        let longitude = decoder.decodeDouble(forKey: LocationKey.longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        radius = decoder.decodeDouble(forKey: LocationKey.radius)
        identifier = decoder.decodeObject(forKey: LocationKey.identifier) as! String
        note = decoder.decodeObject(forKey: LocationKey.note) as! String
        eventType = EventType(rawValue: decoder.decodeObject(forKey: LocationKey.eventType) as! String)!
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(coordinate.latitude, forKey: LocationKey.latitude)
        coder.encode(coordinate.longitude, forKey: LocationKey.longitude)
        coder.encode(radius, forKey: LocationKey.radius)
        coder.encode(identifier, forKey: LocationKey.identifier)
        coder.encode(note, forKey: LocationKey.note)
        coder.encode(eventType.rawValue, forKey: LocationKey.eventType)
    }
    
}

