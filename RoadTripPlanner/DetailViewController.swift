//
//  DetailViewController.swift
//  RoadTripPlanner
//
//  Created by Allen Fang, Alan Le, Harrison Mai, and Sam Moon on 6/1/17.
//  Copyright © 2017 Allen Fang, Alan Le, Harrison Mai, and Sam Moon. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController, MKMapViewDelegate {
    
    var placeID: String?
    var name: String?
    var rating: Double?
    var price: Double?
    var hours: String?
    var address: String?
    var long: Double?
    var lat: Double?
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(placeID!)
        var url = URL(string: "")
        if let place_id = self.placeID {
            url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(place_id)&key=AIzaSyCuhXz3sXuZhqB3_DCNHptu7gn7YLgdOH4")
        }
        
        let session = URLSession.shared
        print(url!)

        let task = session.dataTask(with: url! as URL, completionHandler: {
            data, response, error in
            do {
                print("HEllo!!!!!")
                print(data!)
                print("WHAT'S GOING ON")
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    if let result = jsonResult["result"] as? NSDictionary {
                        print(result)
                        let geometry = result["geometry"] as! NSDictionary
                        let location = geometry["location"] as! NSDictionary
                        self.lat = location["lat"] as? Double
                        self.long = location["lng"] as? Double
                        self.name = result["name"] as? String
                        self.rating = result["rating"] as? Double
                        self.price = result["price_level"] as? Double
                        self.address = result["formatted_address"] as? String
                        let opentimes = result["opening_hours"] as! NSDictionary
                        let weekday_text = opentimes["weekday_text"] as! NSArray
                        print(weekday_text, "weeldau text")
                        print(opentimes, "opentimes")
                        self.hours = ""
                        for var weekday in weekday_text {
                            if let weekdaystring = weekday as? String {
                                 self.hours = self.hours! + weekdaystring + "\n"
                                print(self.hours)
                            }
                           
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.titleLabel.text = self.name
                    self.ratingLabel.text = "\(self.rating!)"
                    if self.rating! > 3.9 {
                        self.ratingLabel.textColor = UIColor.green
                    } else if self.rating! > 2.5 {
                        self.ratingLabel.textColor = UIColor.orange
                    } else {
                        self.ratingLabel.textColor = UIColor.red
                    }

                    var priceLabelText = ""
                    if let numDollarSigns = self.price {
                        for _ in 0..<Int(numDollarSigns) {
                            priceLabelText += "💰"
                        }
                    } else {
                        priceLabelText = ""
                    }
                    self.priceLabel.text = priceLabelText
                    self.addressLabel.text = self.address
                    self.hoursLabel.text = self.hours
                    let coordinate = CLLocationCoordinate2D(latitude: self.lat!, longitude: self.long!)
                    self.dropPin(coordinate: coordinate)
                    
                }
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

// MAPKIT STUFF
extension DetailViewController {
    
    func dropPin(coordinate: CLLocationCoordinate2D) {
        let coordinate = coordinate
        let locationPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: locationPlacemark)
        let annotation = MKPointAnnotation ()
        if let location = locationPlacemark.location {
            annotation.coordinate = location.coordinate
        }
        self.mapView.showAnnotations([annotation], animated: false)
    }
}
    
//    func getDirections(sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
//        let sourceLocation = sourceCoordinate
//        let destinationLocation = destinationCoordinate
//        
//        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
//        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
//        
//        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
//        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
//        
//        let sourceAnnotation = MKPointAnnotation ()
//        if let location = sourcePlacemark.location {
//            sourceAnnotation.coordinate = location.coordinate
//        }
//        let destinationAnnotation = MKPointAnnotation ()
//        if let location = destinationPlacemark.location {
//            destinationAnnotation.coordinate = location.coordinate
//        }
//        
//        
//        
//        let directionRequest = MKDirectionsRequest()
//        directionRequest.source = sourceMapItem
//        directionRequest.destination = destinationMapItem
//        directionRequest.transportType = .automobile
//        
//        let directions = MKDirections(request: directionRequest)
//        
//        directions.calculate{
//            (response, error) -> Void in
//            
//            guard let response = response else {
//                if let error = error {
//                    print("Error: \(error)")
//                }
//                return
//            }
//            print("function got past error control")
//            let route = response.routes[0]
//            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
//        }
//        
//        if sourceCoordinate.latitude == locationManager.location!.coordinate.latitude && sourceCoordinate.longitude == locationManager.location!.coordinate.longitude {
//            self.mapView.showAnnotations([destinationAnnotation], animated: true)
//        } else {
//            self.mapView.showAnnotations([sourceAnnotation, destinationAnnotation], animated: true)
//        }
//    }
//    
//    func createRoute(restaurantCoordinate: CLLocationCoordinate2D) {
//        getDirections(sourceCoordinate: locationManager.location!.coordinate, destinationCoordinate: restaurantCoordinate)
//    }
//    
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        let renderer = MKPolylineRenderer(overlay: overlay)
//        renderer.strokeColor = UIColor.blue
//        renderer.lineWidth = 4.0
//        
//        return renderer
//        
//    }


//self.placeID = result["place_id"] as? String
//
//RestaurantModel.getRestaurantWithID(id: self.placeID!, completionHandler: {
//    data, response, error in
//    do {
//        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
//            if let restaurant = jsonResult["result"] as? NSDictionary {
//                self.name = restaurant["name"] as? String
//                self.rating = restaurant["rating"] as? Double
//                self.price = restaurant["price_level"] as? Double
//                self.address = restaurant["formatted_address"] as? String
//                let geometry = restaurant["geometry"] as! NSDictionary
//                let location = geometry["location"] as! NSDictionary
//                self.lat = location["lat"] as? Double
//                self.long = location["lng"] as? Double
//                self.phone = restaurant["formatted_phone_number"] as? String
//                self.website = restaurant["website"] as? String
//            }
//        }
//        DispatchQueue.main.async {
//            self.nameLabel.text = self.name
//            self.ratingLabel.text = "\(self.rating!)"
//            if self.rating! > 3.9 {
//                self.ratingLabel.textColor = UIColor.green
//            } else if self.rating! > 2.5 {
//                self.ratingLabel.textColor = UIColor.orange
//            } else {
//                self.ratingLabel.textColor = UIColor.red
//            }
//            var priceLabelText = "Price: "
//            if let numDollarSigns = self.price {
//                for _ in 0..<Int(numDollarSigns) {
//                    priceLabelText += "💰"
//                }
//            } else {
//                priceLabelText += "not listed"
//            }
//            self.priceLevelLabel.text = priceLabelText
//            self.addressLabel.text = self.address!
//            self.phoneButtonLabel.setTitle(self.phone, for: UIControlState.normal)
//            print(self.lat!)
//            print(self.long!)
//            self.createRoute(restaurantCoordinate: CLLocationCoordinate2D(latitude: self.lat!, longitude: self.long!))
//            self.overlay?.removeFromSuperview()
//        }
