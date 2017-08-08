//
//  LocationInfoViewController.swift
//  RoadTripPlanner
//
//  Created by Allen Fang, Alan Le, Harrison Mai, and Sam Moon on 5/18/17.
//  Copyright © 2017 Allen Fang, Alan Le, Harrison Mai, and Sam Moon. All rights reserved.
//

import UIKit
import GooglePlaces

class LocationInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var welcomeBackground: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var locationName: String?
    var locationID: String?
    var delegate: LocationInfoViewControllerDelegate?
    var welcomeImage: UIImage?
    var locationCoordinate: CLLocationCoordinate2D?
    
    var poiplaceIDs: [String] = []
    var lodgingplaceIDs: [String] = []
    var foodplaceIDs: [String] = []
    
    var poiNames: [String] = []
    var poiImages: [UIImage] = []
    var poiRatings: [NSNumber] = []
    
    var lodgingNames: [String] = []
    var lodgingImages: [UIImage] = []
    var lodgingRatings: [NSNumber] = []
    
    var foodNames: [String] = []
    var foodImages: [UIImage] = []
    var foodRatings: [NSNumber] = []
    
    let myGroup = DispatchGroup()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        runSearchesLodging()
        runSearchesPOI()
        runSearchesFood()
        let name = NSMutableParagraphStyle()
        name.alignment = .center
        let strokeTextAttributes1 = [
            NSStrokeColorAttributeName : UIColor.white,
            NSForegroundColorAttributeName: UIColor.white,
            NSStrokeWidthAttributeName: -4.0,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 30),
            NSParagraphStyleAttributeName: name
            ] as [String: Any]
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.locationNameLabel.attributedText = NSMutableAttributedString(string: self.locationName!, attributes: strokeTextAttributes1)
        self.welcomeBackground.image = self.welcomeImage!
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) { 
            self.myGroup.notify(queue: .main){
                super.viewDidLoad()
    
                
                self.tableView.dataSource = self
                self.tableView.delegate = self
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailSegue", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMapSegue" {
            let mapController = segue.destination as! ShowMapViewController
            mapController.locationCoordinate = locationCoordinate
            mapController.locationName = locationName
        }
        if segue.identifier == "detailSegue" {
            let indexPath = sender as! NSIndexPath
            let nav = segue.destination as! UINavigationController
            let detailController = nav.topViewController as! DetailViewController
            switch indexPath.section{
            case 0:
                detailController.placeID = poiplaceIDs[indexPath.row]
            case 1:
                detailController.placeID = foodplaceIDs[indexPath.row]
            case 2:
                detailController.placeID = lodgingplaceIDs[indexPath.row]
            default:
                print("error")
            }
        }
    }
    
    @IBAction func showMapButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showMapSegue", sender: sender)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Points of Interest"
        } else if (section == 1) {
            return "Restaurants"
        } else if (section == 2) {
            return "Lodging"
        } else {
            return " "
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return poiNames.count
        } else if section == 2{
            return lodgingNames.count
        } else if section == 1 {
            return foodNames.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! InfoCell

        let strokeTextAttributes1 = [
            NSStrokeColorAttributeName : UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSStrokeWidthAttributeName: -2.0,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)
            ] as [String: Any]
        
        let strokeTextAttributes2 = [
            NSStrokeColorAttributeName : UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSStrokeWidthAttributeName: -2.0,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)
            ] as [String: Any]
        
        if indexPath.section == 2 {
            cell.infoImage.image = self.lodgingImages[indexPath.row]
            cell.nameLabel.attributedText = NSMutableAttributedString(string: lodgingNames[indexPath.row], attributes: strokeTextAttributes1)
            cell.ratingLabel.attributedText = NSMutableAttributedString(string: "\(self.lodgingRatings[indexPath.row])/5", attributes: strokeTextAttributes2)
            cell.distanceLabel.text = ""
        } else if indexPath.section == 1 {
            cell.infoImage.image = self.foodImages[indexPath.row]
            cell.nameLabel.attributedText = NSMutableAttributedString(string: foodNames[indexPath.row], attributes: strokeTextAttributes1)
            cell.ratingLabel.attributedText = NSMutableAttributedString(string: "\(self.foodRatings[indexPath.row])/5", attributes: strokeTextAttributes2)
            cell.distanceLabel.text = ""
        } else if indexPath.section == 0 {
            cell.infoImage.image = self.poiImages[indexPath.row]
            cell.nameLabel.attributedText = NSMutableAttributedString(string: poiNames[indexPath.row], attributes: strokeTextAttributes1)
            cell.ratingLabel.attributedText = NSMutableAttributedString(string: "\(self.poiRatings[indexPath.row])/5", attributes: strokeTextAttributes2)
            cell.distanceLabel.text = ""
        }
        return cell
    }
    
    func runSearchesLodging() {
        let locationNameUrl = locationName!.replacingOccurrences(of: " ", with: "+")
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/textsearch/json?query=lodging+in+\(locationNameUrl)&key=AIzaSyCuhXz3sXuZhqB3_DCNHptu7gn7YLgdOH4")
        let session = URLSession.shared

        let task = session.dataTask(with: url! as URL, completionHandler: {
            data, response, error in
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    if let results = jsonResult["results"] as? NSArray {
                        for i in 0...2 {
                            self.myGroup.enter()
                            let dict = results[i] as! NSDictionary
                            self.lodgingNames.append(dict["name"]! as! String)
                            self.lodgingRatings.append(dict["rating"]! as! NSNumber)
                            self.loadFirstPhotoForPlace(placeID: dict["place_id"]! as! String)
                            self.lodgingplaceIDs.append(dict["place_id"]! as! String)
                        }
                    }
                }
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    func runSearchesPOI() {
        let locationNameUrl = locationName!.replacingOccurrences(of: " ", with: "+")
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/textsearch/json?query=points+of+interest+in+\(locationNameUrl)&key=AIzaSyCuhXz3sXuZhqB3_DCNHptu7gn7YLgdOH4")
        let session = URLSession.shared
        
        let task = session.dataTask(with: url! as URL, completionHandler: {
            data, response, error in
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    if let results = jsonResult["results"] as? NSArray {
                        for i in 0...2 {
                            self.myGroup.enter()
                            let dict = results[i] as! NSDictionary
                            self.poiNames.append(dict["name"]! as! String)
                            self.poiRatings.append(dict["rating"]! as! NSNumber)
                            self.loadFirstPhotoForPoiPlace(placeID: dict["place_id"]! as! String)
                            self.poiplaceIDs.append(dict["place_id"]! as! String)
                        }
                    }
                }
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    func runSearchesFood() {
        let locationNameUrl = locationName!.replacingOccurrences(of: " ", with: "+")
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/textsearch/json?query=restaurants+in+\(locationNameUrl)&key=AIzaSyCuhXz3sXuZhqB3_DCNHptu7gn7YLgdOH4")
        let session = URLSession.shared
        
        let task = session.dataTask(with: url! as URL, completionHandler: {
            data, response, error in
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    if let results = jsonResult["results"] as? NSArray {
                        for i in 0...2 {
                            self.myGroup.enter()
                            let dict = results[i] as! NSDictionary
                            self.foodNames.append(dict["name"]! as! String)
                            self.foodRatings.append(dict["rating"]! as! NSNumber)
                            self.loadFirstPhotoForFoodPlace(placeID: dict["place_id"]! as! String)
                            self.foodplaceIDs.append(dict["place_id"]! as! String)
                        }
                    }
                }
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    
    func loadFirstPhotoForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto)
                }
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                self.lodgingImages.append(photo!)
                self.myGroup.leave()
            }
        })
    }
    
    func loadFirstPhotoForPoiPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadataPoi(photoMetadata: firstPhoto)
                }
            }
        }
    }
    
    func loadImageForMetadataPoi(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                self.poiImages.append(photo!)
                self.myGroup.leave()
            }
        })
    }
    
    func loadFirstPhotoForFoodPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadataFood(photoMetadata: firstPhoto)
                }
            }
        }
    }
    
    func loadImageForMetadataFood(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                self.foodImages.append(photo!)
                self.myGroup.leave()
            }
        })
    }
    
    // back button pressed
    @IBAction func backButtonPresesd(_ sender: UIBarButtonItem) {
        delegate?.backButtonPressed(by: self)
    }
    
    func metersToMiles(_ meters: Double) -> Double {
        return meters / 1609.344
    }
    
}
