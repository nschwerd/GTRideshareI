//
//  OnboardingDriverViewController.swift
//  GT Rideshare
//
//  Created by Jeremy Schonfeld on 2/17/19.
//  Copyright © 2019 Jeremy Schonfeld. All rights reserved.
//

import UIKit

class OnboardingDriverViewController: UIViewController {
    
    @IBOutlet weak var driverSwitch: UISwitch!
    @IBOutlet weak var seatsField: UITextField!
    
    @IBAction func onDriverSwitchChange(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(onNextPress))
    }
    
    @objc func onNextPress() {
        let nav = self.navigationController as! OnboardingNavigationController
        nav.willingToDrive = driverSwitch.isOn
        nav.seats = seatsField.text != nil ? Int(seatsField.text!) : nil
        nav.buildUser()
    }
}
