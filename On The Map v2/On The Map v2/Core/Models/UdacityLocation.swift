//
//  UdacityLocation.swift
//  onTheMap
//
//  Created by César Ferreira on 17/04/21.
//

import UIKit
import MapKit

class UdacityLocation: NSObject, MKAnnotation {

    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String

    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}
