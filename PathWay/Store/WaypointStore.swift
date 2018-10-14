//
//  WaypointStore.swift
//  PathWay
//
//  Created by Matthew Krager on 10/12/18.
//  Copyright © 2018 Matthew Krager. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class WaypointStore: NSObject {
    private override init() {}
    static let shared = WaypointStore()
    
    func getWaypointsForLocation(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance, callback: @escaping ([Waypoint]) -> Void) {
        var dictionary = Dictionary<String, Any>()
        dictionary["altitude"] = altitude
        dictionary["latitude"] = coordinate.latitude
        dictionary["longitude"] = coordinate.longitude
        
        Alamofire.request("\(Backend.baseURL)/all", method: .get, parameters: dictionary, encoding: URLEncoding.default,  headers: nil).responseJSON { (response) in
            let jsonDecoder = JSONDecoder()
            guard let data = response.data else {
                return
            }
            do {
                let waypoints = try jsonDecoder.decode([Waypoint].self, from: data)
                callback(waypoints)
            } catch let error {
                print(error)
            }
        }
    }
    
    func createWaypoint(name: String, coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance, callback: ((Waypoint) -> Void)?) {
        var dictionary = Dictionary<String, Any>()
        dictionary["name"] = name
        dictionary["altitude"] = altitude
        dictionary["latitude"] = coordinate.latitude
        dictionary["longitude"] = coordinate.longitude
        
        print("\(Backend.baseURL)/add/")
        Alamofire.request("\(Backend.baseURL)/add/", method: .post, parameters: dictionary, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            let jsonDecoder = JSONDecoder()
            guard let data = response.data else {
                return
            }
            do {
                let waypoint = try jsonDecoder.decode(Waypoint.self, from: data)
                callback?(waypoint)
            } catch let error {
                print(error)
            }
        }
    }
}
