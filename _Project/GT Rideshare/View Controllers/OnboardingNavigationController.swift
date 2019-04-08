//
//  OnboardingNavigationController.swift
//  GT Rideshare
//
//  Created by Jeremy Schonfeld on 2/17/19.
//  Copyright © 2019 Jeremy Schonfeld. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class OnboardingNavigationController: UINavigationController {
    var name: String?
    var phone: String?
    var location: GeoPoint?
    var schedule: Schedule?
    var seats: Int?
    var willingToDrive: Bool?
    
    public func buildUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            fatalError("Unable to create user while not logged in")
        }
        let user = User(uid: uid, name: name!, phone: phone!, location: location!, schedule: schedule!, seats: seats, willingToDrive: willingToDrive!)
        UserUtil.updateUser(user) { (success) in
            if let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "mainNavController") {
                self.present(mainVC, animated: false, completion: {
                    let alert = UIAlertController(title: success ? "Success" : "Error", message: success ? "User profile created!" : "An error ocurred, please try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                    mainVC.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
}
