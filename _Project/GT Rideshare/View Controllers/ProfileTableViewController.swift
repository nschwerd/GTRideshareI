//
//  ProfileTableViewController.swift
//  GT Rideshare
//
//  Created by Jeremy Schonfeld on 4/7/19.
//  Copyright © 2019 Jeremy Schonfeld. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class ProfileTableViewController: UITableViewController {
    var profile: User? = nil
    var currentUser: User? = nil
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var willingToDriveLabel: UILabel!
    @IBOutlet weak var seatsLabel: UILabel!
    @IBOutlet weak var seatsCell: UITableViewCell!
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    
    override func viewDidLoad() {
        self.navigationItem.title = profile?.name
        self.distanceLabel.text = "\(round((currentUser!.location.distanceFrom(profile!.location) / 1609.0) * 100.0) / 100.0) miles away"
        self.willingToDriveLabel.text = (profile?.willingToDrive ?? false) ? "Yes" : "No"
        self.seatsLabel.text = "\(profile!.seats ?? 0)"
        self.mondayLabel.text = profile?.schedule.monday
        self.tuesdayLabel.text = profile?.schedule.tuesday
        self.wednesdayLabel.text = profile?.schedule.wednesday
        self.thursdayLabel.text = profile?.schedule.thursday
        self.fridayLabel.text = profile?.schedule.friday
        self.phoneLabel.text = profile?.phone
        
        if isOwnProfile() {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(onSignOut))
        }
    }
    
    private func isOwnProfile() -> Bool {
        return self.currentUser?.uid == self.profile?.uid
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = true
    }
    
    @objc func onSignOut() {
        do {
            try Auth.auth().signOut()
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") {
                self.present(vc, animated: false, completion: nil)
            }
        } catch {
            print("An error ocurred while signing out")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.section == 2) {
            if let url = URL(string: "tel://\(profile!.phone)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            return
        }
        
        if isOwnProfile() {
            var user = self.currentUser!
            if indexPath.section == 0 {
                if indexPath.row == 1 {
                    let alert = UIAlertController(title: "Willing to Drive?", message: "Are you willing to drive in a carpool?", preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                        user.willingToDrive = true
                        UserUtil.updateUser(user)
                        self.willingToDriveLabel.text = "Yes"
                    }))
                    alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                        user.willingToDrive = false
                        UserUtil.updateUser(user)
                        self.willingToDriveLabel.text = "No"
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else if indexPath.row == 2 {
                    let alert = UIAlertController(title: "Number of Seats", message: "How many seats do you have available", preferredStyle: .alert)
                    alert.addTextField { (field) in
                        field.keyboardType = .numberPad
                        field.returnKeyType = .done
                    }
                    alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
                        let text = alert.textFields?[0].text ?? ""
                        let num = Int(text)
                        if num != nil && text != "" {
                            user.seats = num
                            UserUtil.updateUser(user)
                            self.seatsLabel.text = "\(user.seats!)"
                        } else {
                            let alert2 = UIAlertController(title: "Error", message: "Invalid number of seats!", preferredStyle: .alert)
                            alert2.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                            self.present(alert2, animated: true, completion: nil)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
