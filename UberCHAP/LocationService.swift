//
//  LocationService.swift
//  UberCHAP
//
//  Created by Andy Cho on 2016-09-17.
//  Copyright © 2016 Students Concerned About Party Night. All rights reserved.
//

import UIKit
import MapKit

protocol LocationServiceDelegate {
    func locationDidUpdate(coordinate: CLLocationCoordinate2D)
}

class LocationService: NSObject, CLLocationManagerDelegate {

    static let latitudeKey = "LATITUDE"
    static let longitudeKey = "LONGITUDE"

    var delegate: LocationServiceDelegate?
    let locationManager = CLLocationManager()

    override init() {
        super.init()

        // RIP battery life
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self

        // Ask the user for permission to use location
        locationManager.requestAlwaysAuthorization()
    }

    func toggle(enable: Bool) {
        if enable {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
        }
    }

    static func saveHomeLocation(coordinate: CLLocationCoordinate2D) {
        let userDefaults = getInstance()
        userDefaults.setObject(coordinate.latitude, forKey: LocationService.latitudeKey)
        userDefaults.setObject(coordinate.longitude, forKey: LocationService.longitudeKey)
        print("Saved home location \(coordinate)")
    }

    static func getHomeLocation() -> CLLocationCoordinate2D? {
        let userDefaults = getInstance()
        guard let
            latitude = userDefaults.objectForKey(LocationService.latitudeKey) as? CLLocationDegrees,
            longitude = userDefaults.objectForKey(LocationService.longitudeKey) as? CLLocationDegrees else {
            return nil
        }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        print("Got home location \(coordinate)")
        return coordinate
    }

    static private func getInstance() -> NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }

    // MARK: CLLocationManagerDelegate

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.count > 0 else { return }
        
        let coordinate = locations[0].coordinate
        
        if UIApplication.sharedApplication().applicationState == .Active {
            print("Foreground location: \(coordinate)")
        } else {
            print("Background location: \(coordinate)")
        }
        delegate?.locationDidUpdate(coordinate)
    }

}
