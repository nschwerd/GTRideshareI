//
//  OnboardingLocationViewController.swift
//  GT Rideshare
//
//  Created by Jeremy Schonfeld on 2/17/19.
//  Copyright © 2019 Jeremy Schonfeld. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CoreLocation

class OnboardingLocationViewController: UIViewController, CLLocationManagerDelegate {
    let locManager = CLLocationManager()
    
    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(onNextPress))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        locManager.delegate = self
        if (CLLocationManager.authorizationStatus() != .authorizedWhenInUse) {
            locManager.requestWhenInUseAuthorization()
        } else {
            locManager.requestLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse) {
            locManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    @objc func onNextPress() {
        let nav = self.navigationController as! OnboardingNavigationController
        if let loc = locManager.location {
            nav.location = GeoPoint(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "onboardingSchedule")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
