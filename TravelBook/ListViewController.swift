//
//  ListViewController.swift
//  TravelBook
//
//  Created by skrzymo on 24/01/2019.
//  Copyright © 2019 skrzymo. All rights reserved.
//

import UIKit
import CoreData
import FBSDKLoginKit
import FBSDKCoreKit

var places: [NSManagedObject] = []
var choosenPlaceIndex: Int!

class ListViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addPlaceButton: UIBarButtonItem!
    @IBOutlet weak var deletePlaceButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.isUserInteractionEnabled = true
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: CustomTableViewCell.reusableIdentifier)
        tableView.rowHeight = 70.0
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        choosenPlaceIndex = nil
        
        if FBSDKAccessToken.current() == nil {
            let main = UIStoryboard(name: "Main", bundle: Bundle.main)
            let authenticate = main.instantiateViewController(withIdentifier: "Authentication")
            
            self.present(authenticate, animated: true, completion: nil)
        }
        
        if UserDetails.name == nil {
            fetchProfile()
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewPlaces")
        
        do {
            places.removeAll()
            let userPlaces = try managedContext.fetch(fetchRequest)
            for place in userPlaces {
                if (place.value(forKey: "name") as? String) == UserDetails.name {
                    places.append(place)
                }
        }
            
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
    }
    
    func fetchProfile() {
        let parameters = ["fields": "name, picture"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters)?.start { (connection, result, error) -> Void in
            if error != nil {
                print(error as Any)
                return
            }
            
            if let userInfo = result as? [String: Any] {
                self.nameLabel.text = userInfo["name"] as? String
                UserDetails.name = userInfo["name"] as? String
                self.viewWillAppear(true)
            }
        }
    }
    
    @IBAction func addPlaceAction(_ sender: Any) {
        performSegue(withIdentifier: "addPlace", sender: nil)
    }
    
    @IBAction func deletePlaceAction(_ sender: Any) {
        performSegue(withIdentifier: "deletePlace", sender: nil)
    }
    @IBAction func logoutAction(_ sender: Any) {
        performSegue(withIdentifier: "logout", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPlace" {
            let addController = segue.destination as! UINavigationController
            addController.title = "AddPlace"
        } else if segue.identifier == "deletePlace" {
            let deleteController = segue.destination as! UINavigationController
            deleteController.title = "DeletePlace"
        } else if segue.identifier == "logout" {
            let logoutController = segue.destination as! AuthenticationController
            logoutController.title = "Logout"
        }
    }
}
    
extension ListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place = places[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.reusableIdentifier, for: indexPath) as! CustomTableViewCell
        cell.country.text = place.value(forKeyPath: "country") as? String
        cell.title.text = place.value(forKeyPath: "title") as? String
        
        return cell
    }

}

extension ListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell number: \(indexPath.row)!")
        choosenPlaceIndex = indexPath.row
        self.performSegue(withIdentifier: "addPlace", sender: self)
    }
}


