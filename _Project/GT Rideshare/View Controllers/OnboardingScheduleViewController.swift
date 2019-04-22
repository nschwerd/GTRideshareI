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
    
    private static let REGEX = "[0-9]?[0-9] [a,A,p,P][m,M] \\- [0-9]?[0-9] [a,A,p,P][m,M]"
    
    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(onNextPress))
    }
    
    @objc func onNextPress() {
        
        for value in [mondayField.text, tuesdayField.text, wednesdayField.text, thursdayField.text, fridayField.text] {
            if value != nil && value != "" && value?.range(of: OnboardingScheduleViewController.REGEX, options: .regularExpression, range: nil, locale: nil) == nil {
                let alert = UIAlertController(title: "Error", message: "Please input all times as\n'X am/pm - X am/pm", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
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
