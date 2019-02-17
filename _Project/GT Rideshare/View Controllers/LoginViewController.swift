//
//  LoginViewController.swift
//  GT Rideshare
//
//  Created by Jeremy Schonfeld on 1/25/19.
//  Copyright © 2019 Jeremy Schonfeld. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func onLogin(_ sender: Any) {
        guard let email = emailField.text, let password = passwordField.text, email != "", password != "" else {
            let alert = UIAlertController(title: "Error", message: "Please fill out all required fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            guard let _ = result else {
                let alert = UIAlertController(title: "Error", message: "An unknown error ocurred. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "onboardingNav")
            self.present(vc!, animated: true, completion: nil)
            return
        }
    }
}
