//
//  OnboardingScheduleViewController.swift
//  GT Rideshare
//
//  Created by Jeremy Schonfeld on 2/17/19.
//  Copyright © 2019 Jeremy Schonfeld. All rights reserved.
//

import UIKit

class OnboardingScheduleViewController: UIViewController {
    
    @IBOutlet weak var mondayField: UITextField!
    @IBOutlet weak var tuesdayField: UITextField!
    @IBOutlet weak var wednesdayField: UITextField!
    @IBOutlet weak var thursdayField: UITextField!
    @IBOutlet weak var fridayField: UITextField!
    
    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(onNextPress))
    }
    
    @objc func onNextPress() {
        let schedule = Schedule(
            monday: mondayField.text,
            tuesday: tuesdayField.text,
            wednesday: wednesdayField.text,
            thursday: thursdayField.text,
            friday: fridayField.text
        )
        let nav = self.navigationController as! OnboardingNavigationController
        nav.schedule = schedule
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "onboardingDriver")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
