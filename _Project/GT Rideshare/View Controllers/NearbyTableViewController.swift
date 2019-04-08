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

class NearbyTableViewController: UITableViewController {
    
    var users: [User] = []
    var currentUser: User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
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
            cell.detailTextLabel?.text = "\(round((dist / 1609.0) * 100.0) / 100.0) miles away"
        }
        return cell!
    }
    
    private func loadData() {
        self.refreshControl?.beginRefreshing()
        UserUtil.retrieveAllUsers { (users) in
            self.users = users ?? []
            self.currentUser = users?.filter({$0.uid == Auth.auth().currentUser?.uid}).first
            self.users = users?.filter({$0.uid != Auth.auth().currentUser?.uid}) ?? []
            self.users.sort(by: { (a, b) -> Bool in
                self.currentUser!.location.distanceFrom(a.location) < self.currentUser!.location.distanceFrom(b.location)
            })
            print("Did retrieve all \(users?.count ?? -1) users")
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
}
