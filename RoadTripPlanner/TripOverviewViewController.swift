//
//  ViewController.swift
//  RoadTripPlanner
//
//  Created by Allen Fang, Alan Le, Harrison Mai, and Sam Moon on 5/18/17.
//  Copyright © 2017 Allen Fang, Alan Le, Harrison Mai, and Sam Moon. All rights reserved.
//

import UIKit
import GooglePlaces

class TripOverviewViewController: UITableViewController, CLLocationManagerDelegate {

    var locations: [String] = []
    var locationIDs: [String] = []
    var locationImages: [UIImage] = []
    var locationCoordinates: [CLLocationCoordinate2D] = []
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
        navigationController?.navigationBar.barTintColor = UIColor(red:0.34, green:0.65, blue:0.96, alpha:1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
        UIApplication.shared.statusBarStyle = .lightContent
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(gestureRecognizer:)))
        tableView.addGestureRecognizer(longpress)
    }
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer){
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        
        let locationInView = longPress.location(in: tableView)
        var indexPath = tableView.indexPathForRow(at: locationInView)
        
        struct My{
            static var cellSnapshot: UIView? = nil
        }
        struct Path {
            static var initialIndexPath: NSIndexPath? = nil
        }
        
        switch state {
        case UIGestureRecognizerState.began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath! as NSIndexPath
                let cell = tableView.cellForRow(at: indexPath!) as UITableViewCell!
                My.cellSnapshot = snapShotOfCell(inputView: cell!)
                var center = cell?.center
                My.cellSnapshot!.center = center!
                My.cellSnapshot!.alpha = 0.0
                tableView.addSubview(My.cellSnapshot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationInView.y
                    My.cellSnapshot!.center = center!
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell?.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        cell?.isHidden = true
                    }
                })
            }
        case UIGestureRecognizerState.changed:
            var center = My.cellSnapshot!.center
            center.y = locationInView.y
            My.cellSnapshot!.center = center
            if ((indexPath != nil) && (indexPath! != Path.initialIndexPath! as IndexPath)) {
                swap(&locations[indexPath!.row], &locations[Path.initialIndexPath!.row])
                swap(&locationIDs[indexPath!.row], &locationIDs[Path.initialIndexPath!.row])
                swap(&locationCoordinates[indexPath!.row], &locationCoordinates[Path.initialIndexPath!.row])
                tableView.moveRow(at: Path.initialIndexPath! as IndexPath, to: indexPath!)
                Path.initialIndexPath = indexPath! as IndexPath as NSIndexPath
            }
        default:
            let cell = tableView.cellForRow(at: Path.initialIndexPath! as IndexPath) as UITableViewCell!
            cell?.isHidden = false
            cell?.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                My.cellSnapshot!.center = (cell?.center)!
                My.cellSnapshot!.transform = CGAffineTransform.identity
                My.cellSnapshot!.alpha = 0.0
                cell?.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    Path.initialIndexPath = nil
                    My.cellSnapshot!.removeFromSuperview()
                    My.cellSnapshot = nil
                }
            })
        }
    }
    
    func snapShotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let cellSnapshot: UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }

    
    // bring up google places autocomplete
    @IBAction func addLocationButtonPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strokeTextAttributes1 = [
            NSStrokeColorAttributeName : UIColor.white,
            NSForegroundColorAttributeName: UIColor.white,
            NSStrokeWidthAttributeName: -4.0,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 30)
            ] as [String: Any]
        
        let strokeTextAttributes2 = [
            NSStrokeColorAttributeName : UIColor.white,
            NSForegroundColorAttributeName: UIColor.white,
            NSStrokeWidthAttributeName: -4.0,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)
            ] as [String: Any]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "stopCell", for: indexPath) as! LocationCell
        let locationName = locations[indexPath.row]
        cell.locationLabel.attributedText = NSMutableAttributedString(string: locationName, attributes: strokeTextAttributes1)
        
        let distance = locationManager.location!.coordinate.distanceTo(coordinate:  locationCoordinates[indexPath.row])
        print(distance, "meters")
        let distanceMiles = Float(metersToMiles(distance))
        print(distanceMiles, "miles")
        let distanceAway = String(format: "%.1f", distanceMiles)
        print(distanceAway)
        cell.milesLabel.attributedText = NSMutableAttributedString(string: "\(distanceAway) mi", attributes: strokeTextAttributes2)
        
        cell.locationImage.image = locationImages[indexPath.row]

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "locationSegue" {
            let navController = segue.destination as! UINavigationController
            let locationInfoViewController = navController.topViewController as! LocationInfoViewController
            locationInfoViewController.delegate = self
            
            let indexPath = sender as! NSIndexPath
            locationInfoViewController.locationName = locations[indexPath.row]
            locationInfoViewController.locationID = locationIDs[indexPath.row]
            locationInfoViewController.welcomeImage = locationImages[indexPath.row]
            locationInfoViewController.locationCoordinate = locationCoordinates[indexPath.row]
        } else if segue.identifier == "routeMapSegue" {
            print("route map segue")
            print(locationCoordinates)
            let routeMapController = segue.destination as! RouteMapViewController
            routeMapController.locationCoordinates = locationCoordinates
        }
    }
    
    @IBAction func routeMapButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "routeMapSegue", sender: sender)
    }
   
    // tap on location to view info on the location
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "locationSegue", sender: indexPath)
    }
    
    // swipe to delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        tableView.beginUpdates()
        locationCoordinates.remove(at: indexPath.row)
        locations.remove(at: indexPath.row)
        locationImages.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }
    
    func metersToMiles(_ meters: Double) -> Double {
        return meters / 1609.344
    }

}


// GOOGLE AUTOCOMPLETE DELEGATE 

extension TripOverviewViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        locations.append(place.name)
        locationIDs.append(place.placeID)
        locationCoordinates.append(place.coordinate)
        loadFirstPhotoForPlace(placeID: place.placeID)
        print("hello world")
        dismiss(animated: true, completion: nil)
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
                print(photo!)
                self.locationImages.append(photo!)
                self.tableView.reloadData()
            }
        })
    }
    
}

extension TripOverviewViewController: LocationInfoViewControllerDelegate {

    func backButtonPressed(by controller: LocationInfoViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}


// function to get distance between two locations
extension CLLocationCoordinate2D {
    func distanceTo(coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let thisLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let otherLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        return thisLocation.distance(from: otherLocation)
    }
}


