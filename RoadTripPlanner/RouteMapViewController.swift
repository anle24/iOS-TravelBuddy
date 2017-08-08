//
//  RouteMapViewController.swift
//  RoadTripPlanner
//
//  Created by Allen Fang, Alan Le, Harrison Mai, and Sam Moon on 5/19/17.
//  Copyright © 2017 Allen Fang, Alan Le, Harrison Mai, and Sam Moon. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RouteMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationCoordinates: [CLLocationCoordinate2D]?
//    var locationPoints: [LocationPoint] = []
    let locationManager = CLLocationManager()
    var userLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        createRoute(withCoordinates: locationCoordinates!)
        mapView.showsUserLocation = true
        mapView.delegate = self
    }
    
    @IBAction func zoomToCurrentLocation(_ sender: UIBarButtonItem) {
        mapView.zoomToUserLocation()
    }
    
    
    // get directions from point A to B
    func getDirections(sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        let sourceLocation = sourceCoordinate
        let destinationLocation = destinationCoordinate
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation ()
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        let destinationAnnotation = MKPointAnnotation ()
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        if sourceCoordinate.latitude == locationManager.location!.coordinate.latitude && sourceCoordinate.longitude == locationManager.location!.coordinate.longitude {
            self.mapView.showAnnotations([destinationAnnotation], animated: true)
        } else {
            self.mapView.showAnnotations([sourceAnnotation, destinationAnnotation], animated: true)
        }
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate{
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            print("function got past error control")
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
        }
    }
    
    func createRoute(withCoordinates: [CLLocationCoordinate2D]) {
        if locationCoordinates!.count > 0 {
            getDirections(sourceCoordinate: locationManager.location!.coordinate, destinationCoordinate: locationCoordinates![0])
            for i in 0..<locationCoordinates!.count - 1 {
                getDirections(sourceCoordinate: locationCoordinates![i], destinationCoordinate: locationCoordinates![i+1])
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
        
    }

    
}

// allows zoom to user location
extension MKMapView {
    func zoomToUserLocation() {
        guard let coordinate = userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
        setRegion(region, animated: true)
    }
}
