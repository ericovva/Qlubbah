//
//  Artwork.swift
//  QlubbahApp
//
//  Created by Эрик on 07.10.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//

import MapKit


class Artwork: NSObject, MKAnnotation {
    let title1: String
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title1 = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle1: String {
        return locationName
    }
}
