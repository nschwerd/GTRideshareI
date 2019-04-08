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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            if let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "mainNavController") {
                self.present(mainVC, animated: false, completion: nil)
            }
        }
    }
    
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
            
            UserUtil.retrieveUser(Auth.auth().currentUser!.uid, callback: { (user) in
                if let _ = user {
                    if let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "mainNavController") {
                        self.present(mainVC, animated: false, completion: nil)
                    }
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "onboardingNav")
                    self.present(vc!, animated: true, completion: nil)
                }
            })
            
            return
        }
    }
}
