//
//  NearbyTableViewController.swift
//  GT Rideshare
//
//  Created by Jeremy Schonfeld on 4/7/19.
//  Copyright © 2019 Jeremy Schonfeld. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import FirebaseAuth
import FirebaseFirestore

enum SortMethod {
    case location
    case schedule
}

class NearbyTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var users: [User] = []
    var currentUser: User? = nil
    let locManager = CLLocationManager()
    var location: CLLocation?
    
    var sortMethod: SortMethod = .location
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        
        locManager.delegate = self
        if (CLLocationManager.authorizationStatus() != .authorizedWhenInUse) {
            locManager.requestWhenInUseAuthorization()
        } else {
            locManager.startUpdatingLocation()
        }
        
    }
    
    @IBAction func onSortButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Sort", message: "What parameter would you like to sort by?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Location", style: .default, handler: { (action) in
            self.sortMethod = .location
            self.loadData()
        }))
        alert.addAction(UIAlertAction(title: "Schedule Matching", style: .default, handler: { (action) in
            self.sortMethod = .schedule
            self.loadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse) {
            locManager.startUpdatingLocation()
        } else {
            let alert = UIAlertController(title: "Error", message: "Please enable location services", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locManager.location
        
        if var _ = self.currentUser {
            self.currentUser!.location = GeoPoint(latitude: self.location?.coordinate.latitude ?? 0.0, longitude: self.location?.coordinate.longitude ?? 0.0)
            UserUtil.updateUser(self.currentUser!)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    @objc func onRefresh() {
        loadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProfileTableViewController {
            vc.profile = self.currentUser
            vc.currentUser = self.currentUser
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "profileController") as? ProfileTableViewController
        vc?.profile = self.users[indexPath.row]
        vc?.currentUser = self.currentUser
        if let vc = vc {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nearbyUserCell")
        
        if let cell = cell {
            let dbLoc = self.users[indexPath.row].location
            let dist = dbLoc.distanceFrom(currentUser!.location)
            cell.textLabel?.text = self.users[indexPath.row].name
            let percent = self.currentUser!.schedule.percentMatching(self.users[indexPath.row].schedule)
            cell.detailTextLabel?.text = "\(round((dist / 1609.0) * 100.0) / 100.0) miles away - \(Int(percent * 100))% Schedule Match"
        }
        return cell!
    }
    
    private func loadData() {
        self.refreshControl?.beginRefreshing()
        UserUtil.retrieveCurrentUser { (cU) in
            guard let cU = cU else {
                do {
                try Auth.auth().signOut()
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") {
                        self.present(vc, animated: false, completion: nil)
                    }
                } catch {
                    print("Error signing out")
                }
                return
            }
            self.currentUser = cU
            if let loc = self.location {
                self.currentUser!.location = GeoPoint(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
                UserUtil.updateUser(self.currentUser!)
            }
            UserUtil.retrieveAllUsers { (users) in
                self.users = users ?? []
                self.users = users?.filter({$0.uid != Auth.auth().currentUser?.uid}) ?? []
                self.users.sort(by: { (a, b) -> Bool in
                    if (self.sortMethod == .location) {
                        return self.currentUser!.location.distanceFrom(a.location) < self.currentUser!.location.distanceFrom(b.location)
                    } else {
                        return self.currentUser!.schedule.percentMatching(a.schedule) > self.currentUser!.schedule.percentMatching(b.schedule)
                    }
                })
                print("Did retrieve all \(users?.count ?? -1) users")
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }
}
