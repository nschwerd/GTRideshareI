//
//  RegisterViewController.swift
//  GT Rideshare
//
//  Created by Jeremy Schonfeld on 1/25/19.
//  Copyright © 2019 Jeremy Schonfeld. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class RegisterViewController: UIViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func onRegister(_ sender: Any) {
        guard let email = emailField.text, let password = passwordField.text, let name = nameField.text,
            email != "", password != "", name != "" else {
            let alert = UIAlertController(title: "Error", message: "Please fill out all required fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard email.hasSuffix("gatech.edu") else {
            let alert = UIAlertController(title: "Error", message: "You must register with your gatech.edu email address", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
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
            
            
            let alert = UIAlertController(title: "Success", message: "You have successfully created an account", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
}
