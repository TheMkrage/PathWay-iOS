//
//  Waypoint.swift
//  PathWay
//
//  Created by Matthew Krager on 10/12/18.
//  Copyright © 2018 Matthew Krager. All rights reserved.
//

import UIKit
import CoreLocation

class Waypoint: Codable {
    var name: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var altitude: CLLocationDistance
}
