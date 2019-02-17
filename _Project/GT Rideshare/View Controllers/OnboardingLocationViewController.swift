//
//  OnboardingLocationViewController.swift
//  GT Rideshare
//
//  Created by Jeremy Schonfeld on 2/17/19.
//  Copyright © 2019 Jeremy Schonfeld. All rights reserved.
//

import UIKit
import FirebaseFirestore

class OnboardingLocationViewController: UIViewController {
    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(onNextPress))
    }
    
    @objc func onNextPress() {
        let nav = self.navigationController as! OnboardingNavigationController
        nav.location = GeoPoint(latitude: 0, longitude: 0)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "onboardingSchedule")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
