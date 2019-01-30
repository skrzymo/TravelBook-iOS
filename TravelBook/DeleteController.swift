//
//  DeleteController.swift
//  TravelBook
//
//  Created by skrzymo on 24/01/2019.
//  Copyright © 2019 skrzymo. All rights reserved.
//

import UIKit
import CoreData

class DeleteController: UIViewController {

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.isUserInteractionEnabled = true
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = true
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: CustomTableViewCell.reusableIdentifier)
        tableView.rowHeight = 70.0
        tableView.reloadData()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewPlaces")
        
        do {
            places = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
    }
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "backAfterDelete", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backAfterDelete" {
            let addController = segue.destination as! UINavigationController
            addController.title = "BackToListView"
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DeleteController: UITableViewDataSource {
    
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

extension DeleteController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell number: \(indexPath.row)!")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let place = places[indexPath.row]
            
            managedContext.delete(place)
            
            do {
                try managedContext.save()
                places.remove(at: indexPath.row)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            tableView.reloadData()
        }
    }
}
