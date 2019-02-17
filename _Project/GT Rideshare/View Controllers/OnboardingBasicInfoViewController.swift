//
//  OnboardingBasicInfoViewController.swift
//  GT Rideshare
//
//  Created by Jeremy Schonfeld on 2/17/19.
//  Copyright © 2019 Jeremy Schonfeld. All rights reserved.
//

import UIKit

class OnboardingBasicInfoViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    
    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(onNextPress))
    }
    
    @objc func onNextPress() {
        guard let name = nameField.text, let phone = phoneField.text, name != "", phone != "" else {
            let alert = UIAlertController(title: "Error", message: "All fields are required", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let nav = self.navigationController as! OnboardingNavigationController
        nav.name = name
        nav.phone = phone
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "onboardingLocation")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
