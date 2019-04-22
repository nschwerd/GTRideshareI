//
//  DBUtil.swift
//  GT Rideshare
//
//  Created by Jeremy Schonfeld on 2/15/19.
//  Copyright © 2019 Jeremy Schonfeld. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

typealias UserCallback = (User?) -> Void
typealias SuccessCallback = (Bool) -> Void
typealias UsersCallback = ([User]?) -> Void

struct Schedule {
    var monday: String?
    var tuesday: String?
    var wednesday: String?
    var thursday: String?
    var friday: String?
    var data: [(Int, Int)?]
    
    init(monday: String?, tuesday: String?, wednesday: String?, thursday: String?, friday: String?) {
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.data = []
        
        parseData()
    }
    
    init?(_ data: [String:String]) {
        var realData = data as [String:String?]
        for key in realData.keys {
            if realData[key] == "" {
                realData[key] = nil
            }
        }
        guard let monday = realData["monday"],
                let tuesday = realData["tuesday"],
                let wednesday = realData["wednesday"],
                let thursday = realData["thursday"],
                let friday = realData["friday"] else {
            return nil
        }
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.data = []
        
        parseData()
    }
    
    private mutating func parseData() {
        self.data = [monday, tuesday, wednesday, thursday, friday].map({
            let parts = $0?.split(separator: "-")
            let startParts = parts?[0].split(separator: " ")
            let endParts = parts?[1].split(separator: " ")
            print("START: \(startParts?[0].trimmingCharacters(in: .whitespaces))")
            var startTime = Int(startParts?[0].trimmingCharacters(in: .whitespaces) ?? "-1")!
            var endTime = Int(endParts?[0].trimmingCharacters(in: .whitespaces) ?? "-1")!
            if (startParts?[1].lowercased().contains("pm") ?? false) {
                startTime += 12
            }
            if (endParts?[1].lowercased().contains("pm") ?? false) {
                endTime += 12
            }
            return (startTime, endTime)
        })
    }
    
    func dictionary() -> [String:Any] {
        return [
            "monday": monday ?? "",
            "tuesday": tuesday ?? "",
            "wednesday": wednesday ?? "",
            "thursday": thursday ?? "",
            "friday": friday ?? "",
        ]
    }
    
    func percentMatching(_ other: Schedule) -> Double {
        let odata = other.data
        var sum = 0.0
        for i in 0..<odata.count {
            if (data[i] != nil && odata[i] != nil) {
                if (data[i]?.0 == odata[i]?.0) {
                    sum += 1
                }
                if (data[i]?.1 == odata[i]?.1) {
                    sum += 1
                }
            }
        }
        return sum / 10.0
    }
}

struct User {
    var uid: String
    var name: String
    var phone: String
    var location: GeoPoint
    var schedule: Schedule
    var seats: Int?
    var willingToDrive: Bool
    
    init(uid: String, name: String, phone: String, location: GeoPoint, schedule: Schedule, seats: Int?, willingToDrive: Bool) {
        self.uid = uid
        self.name = name
        self.phone = phone
        self.location = location
        self.schedule = schedule
        self.seats = seats
        self.willingToDrive = willingToDrive
    }
    
    init?(_ data: [String: Any], uid: String) {
        guard let name = data["name"] as? String,
                let phone = data["phone"] as? String,
                let location = data["location"] as? GeoPoint,
                let schedule = data["schedule"] as? [String:String],
                let scheduleObj = Schedule(schedule),
                let willingToDrive = data["willingToDrive"] as? Bool else {
                return nil
        }
        self.name = name
        self.phone = phone
        self.location = location
        self.schedule = scheduleObj
        self.seats = data["seats"] as? Int
        if self.seats == -1 {
            self.seats = nil
        }
        self.willingToDrive = willingToDrive
        self.uid = uid
    }
    
    func dictionary() -> [String:Any] {
        return [
            "name": name,
            "phone": phone,
            "location": location,
            "schedule": schedule.dictionary(),
            "seats": seats ?? -1,
            "willingToDrive": willingToDrive
        ]
    }
}

struct UserUtil {
    
    public static func retrieveCurrentUser(callback: @escaping UserCallback) {
        guard let authUser = Auth.auth().currentUser else {
            fatalError("Attempted to retrieve current user when not logged in")
        }
        retrieveUser(authUser.uid, callback: callback)
    }
    
    public static func retrieveUser(_ id: String, callback: @escaping UserCallback) {
        let db = Firestore.firestore()
        db.collection("users").document(id).getDocument { (snapshot, error) in
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    callback(nil)
                }
                return
            }
            
            guard let snapshot = snapshot, let data = snapshot.data(), let user = User(data, uid: id) else {
                DispatchQueue.main.async {
                    callback(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                callback(user)
            }
        }
    }
    
    public static func retrieveAllUsers(callback: @escaping UsersCallback) {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    callback(nil)
                }
                return
            }
            
            guard let documents = snapshot?.documents else {
                DispatchQueue.main.async {
                    callback(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                callback(documents.compactMap({User($0.data(), uid: $0.documentID)}))
            }
        }
    }
    
    public static func updateUser(_ user: User, callback: SuccessCallback? = nil) {
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).setData(user.dictionary()) { (error) in
            if let error = error {
                print(error)
                if let callback = callback {
                    DispatchQueue.main.async {
                        callback(false)
                    }
                }
                return
            }
            if let callback = callback {
                DispatchQueue.main.async {
                    callback(true)
                }
            }
        }
    }
    
}

extension GeoPoint {
    public func distanceFrom(_ other: GeoPoint) -> CLLocationDistance {
        let locA = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let locB = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return locA.distance(from: locB)
    }
}
