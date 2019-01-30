//
//  MapsController.swift
//  TravelBook
//
//  Created by skrzymo on 24/01/2019.
//  Copyright © 2019 skrzymo. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreData

class MapsController: UIViewController, GMSMapViewDelegate, UISearchBarDelegate, LocateOnTheMap {

    
    @IBOutlet weak var backButton: UIBarButtonItem!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var marker: GMSMarker!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var defaultLocation : CLLocation = CLLocation(latitude: -33.86, longitude: 151.20)
    var country: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        print(choosenPlaceIndex)
        
        placesClient = GMSPlacesClient.shared()
        
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "goBackToListView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goBackToListView" {
            let addController = segue.destination as! UINavigationController
            addController.title = "BackToListView"
        }
    }
    
    @IBAction func autoCompleteClicked(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        DispatchQueue.main.async { () -> Void in
            self.mapView.clear()
            
            let position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            self.marker = GMSMarker(position: position)
            
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: self.zoomLevel)
            self.mapView.camera = camera
            
            self.marker.title = "Address: \(title)"
            self.marker.map = self.mapView
            
        }
    }
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        
        let title = self.marker.title
        let snippet = self.marker.snippet
        let name = UserDetails.name
        let latitude = marker.position.latitude
        let longitude = marker.position.longitude
        self.save(country: self.country, title: title!, snippet: snippet!, name: name!, latitude: latitude, longitude: longitude)
        ToastView.shared.short(self.view, txt_msg: "Dodano nowe miejsce")
        
    }
    
    func save(country: String, title: String, snippet: String, name: String, latitude: Double, longitude: Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "NewPlaces", in: managedContext)!
        
        let place = NSManagedObject(entity: entity, insertInto: managedContext)
        
        place.setValue(country, forKeyPath: "country")
        place.setValue(title, forKeyPath: "title")
        place.setValue(snippet, forKeyPath: "snippet")
        place.setValue(name, forKeyPath: "name")
        place.setValue(latitude, forKeyPath: "latitude")
        place.setValue(longitude, forKeyPath: "longitude")
        
        do {
            try managedContext.save()
            places.append(place)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}

extension MapsController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.mapView.clear()
        
        let position = place.coordinate
        self.marker = GMSMarker(position: position)
        
        let camera = GMSCameraPosition.camera(withLatitude: position.latitude, longitude: position.longitude, zoom: zoomLevel)
        self.mapView.camera = camera
        
        let snippet : String = "Adres: \(place.formattedAddress ?? "")\nTel: \(place.phoneNumber ?? "")\nUrl: \(place.website?.absoluteString ?? "")\nOcena: \(place.rating)"
        
        self.marker.title = place.name
        self.marker.snippet = snippet
        self.marker.map = self.mapView
        
        let arrays : NSArray = place.addressComponents! as NSArray
        for i in 0..<arrays.count {
            let disc : GMSAddressComponent = arrays[i] as! GMSAddressComponent
            let str : String = disc.type
            
            if(str == "country") {
                self.country = disc.name
            }
        }
        
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
    
}

extension MapsController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        if choosenPlaceIndex == nil {
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude,
                                                  zoom: zoomLevel)
            
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
            } else {
                mapView.animate(to: camera)
            }
        } else {
            let choosenPlace = places[choosenPlaceIndex]
            let position = CLLocationCoordinate2D(latitude: choosenPlace.value(forKey: "latitude") as! CLLocationDegrees, longitude: choosenPlace.value(forKey: "longitude") as! CLLocationDegrees)
            self.marker = GMSMarker(position: position)
            
            let camera = GMSCameraPosition.camera(withTarget: position, zoom: self.zoomLevel)
            
            self.marker.title = choosenPlace.value(forKey: "title") as? String
            self.marker.snippet = choosenPlace.value(forKey: "snippet") as? String
            self.marker.map = self.mapView
            
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
            } else {
                mapView.animate(to: camera)
            }
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

