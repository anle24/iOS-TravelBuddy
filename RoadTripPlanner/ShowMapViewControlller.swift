//
//  ShowMapViewControlller.swift
//  RoadTripPlanner
//
//  Created by Allen Fang, Alan Le, Harrison Mai, and Sam Moon on 5/19/17.
//  Copyright © 2017 Allen Fang, Alan Le, Harrison Mai, and Sam Moon. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ShowMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationCoordinate: CLLocationCoordinate2D?
    var locationName: String?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        mapView.delegate = self
        mapView.showsUserLocation = true
        let location = CLLocation(latitude: locationCoordinate!.latitude, longitude: locationCoordinate!.longitude)
        print(location)
        centerMapOnLocation(location: location)
        self.title = locationName
    }
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func zoomButtonPressed(_ sender: Any) {
        mapView.zoomToUserLocation()
    }
    
    
}
