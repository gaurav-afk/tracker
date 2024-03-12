//
//  LocationService.swift
//  tracker_ios_app
//
//  Created by macbook on 7/3/2024.
//

import Foundation
import CoreLocation
import FirebaseFirestore
import Contacts

class LocationService: NSObject, CLLocationManagerDelegate, LocationRepositoryDelegate, UpdateFollowingLocationsDelegate {
    private let userService: UserService
    private var locationRepository: LocationRepository
    weak var locationServiceDelegate: LocationServiceDelegate?
    private let geoCoder = CLGeocoder()
    private let locationManager = CLLocationManager()
    private var authorizationStatus : CLAuthorizationStatus = .notDetermined
//    private var currentLocation: CLLocation?
//    private var locationSnapshots: [Waypoint] = []
    private var uncommittedSnapshots: [Waypoint] = []
//    private var takeSnapshotTimer: Timer? = nil
    private var saveSnapshotTimer: Timer? = nil
//    private var snapshotsOfFollowings: [String: [Waypoint]] = [:]
    private var followingListeners: [String: ListenerRegistration] = [:]
    
    init(locationRepository: LocationRepository, userService: UserService) {
        self.locationRepository = locationRepository
        self.userService = userService
        super.init()
        self.userService.updateFollowingLocationsDelegate = self
        self.locationRepository.locationRepositoryDelegate = self
        
        if (CLLocationManager.locationServicesEnabled()){
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        print("before checking permission")
        self.checkPermission()
        
        if (CLLocationManager.locationServicesEnabled() && (self.authorizationStatus == .authorizedAlways || self.authorizationStatus == .authorizedWhenInUse)){
            self.locationManager.startUpdatingLocation()
            
//            self.takeSnapshotTimer = self.startTakingLocationSnapshots(interval: 5)
//            self.startSavingSnapshots(interval: 10)
        }else{
            self.requestPermission()
        }
    }
    
    deinit{
        self.stopLocationUpdates()
    }
    
    func onFollowerUpdated(userData: UserData) {
        print("in location Service, following updated, \(userData.nickName)")
        
        let followingToBeAdded = Set(userData.following.keys).subtracting(followingListeners.keys)
        
        let followingToBeRemoved = Set(followingListeners.keys).subtracting(userData.following.keys)
        
        print("followingtobeadded \(followingToBeAdded)")
        print("followingtoberemoved \(followingToBeRemoved)")
        
        for userId in followingToBeRemoved {
            print("removing listener from \(userId)")
            self.followingListeners[userId]?.remove()
            self.followingListeners.removeValue(forKey: userId)
            
//            self.snapshotsOfFollowings.removeValue(forKey: userId)
        }
        
        for userId in followingToBeAdded {
            print("adding listener on \(userId)")
            
            locationServiceDelegate?.onLocationInit(userId: userId)
            self.followingListeners[userId] = locationRepository.listenToLocationChanges(userId: userId)
            
        }
    }
    
    func onLocationChange(type: DataChangeType, userId: String, wayPoint: Waypoint) {
        print("in location service update on change")
        switch type {
            case .added:
                locationServiceDelegate?.onLocationAdded(userId: userId, waypoint: wayPoint)
            case .updated:
                print("should not update location")
            case .removed:
                print("should not remove location")
        }
    }
    
    func requestPermission(){
        if (CLLocationManager.locationServicesEnabled()){
            print("before request when in use auth")
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    func checkPermission(){
        print("currentPermission is \(self.locationManager.authorizationStatus)")
        switch self.locationManager.authorizationStatus{
        case .denied:
            self.requestPermission()
            
        case .notDetermined:
            self.requestPermission()
            
        case .restricted:
            self.requestPermission()
            
        case .authorizedAlways:
            self.locationManager.startUpdatingLocation()
            
        case .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
            
        default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function, "Authorization Status changed : \(self.locationManager.authorizationStatus)")
        
        self.authorizationStatus = manager.authorizationStatus
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("adding \(locations.count) locations to uncommittedsnapshots")
        let waypoints: [Waypoint] = locations.map { Waypoint(location: $0)}
        self.uncommittedSnapshots.append(contentsOf: waypoints)
//        locationServiceDelegate?.onSelfLocationUpdated(locations: locations)
        locationServiceDelegate?.onSelfLocationUpdated(waypoints: waypoints)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, "Error while trying to get location updates : \(error)")
    }

    
    
    func coordinatesToAddress(coordinates: CLLocation) async throws -> String {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            self.geoCoder.reverseGeocodeLocation(coordinates) { (placemarks, error) in
                guard error == nil else {
                    print("error when reverse coding \(error)")
                    continuation.resume(throwing:  error!)
                    return
                }
                print("reverse coding \(placemarks)")
                
                if let placemarkList = placemarks, let firstPlace = placemarks?.first{
                    // get street address from coordinates
                    
                    let street = firstPlace.thoroughfare ?? "NA"
                    let postalCode = firstPlace.postalCode ?? "NA"
                    let country = firstPlace.country ?? "NA"
                    let province = firstPlace.administrativeArea ?? "NA"
                    
                    print(#function, "\(street), \(postalCode), \(country), \(province)")
                    
                    let address = CNPostalAddressFormatter.string(from: firstPlace.postalAddress!, style: .mailingAddress)
                    print("address is \(address)")
                    continuation.resume(returning: address)
                }
            }
        }
    }
    
    func addressToCoordinates(address: String) async throws -> CLLocation {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CLLocation, Error>) in
            self.geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard error == nil else {
                    print("error when forward coding \(error)")
                    continuation.resume(throwing:  error!)
                    return
                }
                print("forward coding \(placemarks)")
                
                if let place = placemarks?.first{
                    let matchedLocation = place.location!
                    print(#function, "matchedLocation: \(matchedLocation)")
                    continuation.resume(returning: matchedLocation)
                }
            }
        }
    }
    
    func addWaypoints(userId: String, waypoints: [Waypoint]) async throws {
        do {
//            var userIdAndDataTuples: [(String, [AnyHashable: Any])] = []
            var userIdAndDataTuples: [(String, Waypoint)] = []
            
            for location in waypoints {
//                userIdAndDataTuples.append((userId, location.toDictionary()!))
                userIdAndDataTuples.append((userId, location))
            }
            
            try await locationRepository.addWaypoints(userId: userId, waypoints: userIdAndDataTuples)
        }
        catch let error {
            print("in user service, error when adding waypoints: \(error)")
            throw error
        }
    }
    
    // commit the latest snapshots to the database
    func startSavingSnapshots(userId: String, interval: Double) {
        var testingCounter = 0
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            testingCounter += 1
            Task {
                print("testing counter is \(testingCounter)")
                
                do {
                    print("saving location snapshots")
                    
                    // save only some of the uncommittedSnapshots to reduce the number of database operations
                    print("before sampling \(self.uncommittedSnapshots.count) \(self.uncommittedSnapshots)")
                    self.uncommittedSnapshots = self.sampleLocationInInterval(waypoints: self.uncommittedSnapshots, interval: 10)
                    print("after sampling \(self.uncommittedSnapshots.count), \(self.uncommittedSnapshots)")
                    try await self.addWaypoints(userId: userId, waypoints: self.uncommittedSnapshots)
                    
                    // clear uncommitedSnapshots if they are saved successfully
                    self.uncommittedSnapshots = []
                }
                catch let error {
                    print("cannot commit snapshots to db, will try again later: \(error)")
                }
            }
        }
        self.saveSnapshotTimer = timer
//        return timer
    }
    
    // take only the first location with each time interval
    func sampleLocationInInterval(waypoints: [Waypoint], interval: Double) -> [Waypoint] {
        guard !waypoints.isEmpty else {
            print("empty waypoints")
            return []
        }
        
        var currentTime: Date? = nil
        return waypoints.filter {
            if currentTime == nil {
                currentTime = $0.time
                return true
            }
            
            let timeDiff = Double(Int($0.time.timeIntervalSince(currentTime!)) % 60)
            print("time diff is \(timeDiff)")
            
            if timeDiff >= interval {
                print("take this sample")
                currentTime = $0.time
                return true
            }
            return false
            
        }
    }
    
    func startLocationUpdates() {
        print("before checking permission")
        self.checkPermission()
        
        if (CLLocationManager.locationServicesEnabled() && (self.authorizationStatus == .authorizedAlways || self.authorizationStatus == .authorizedWhenInUse)){
            self.locationManager.startUpdatingLocation()
            
//            self.takeSnapshotTimer = self.startTakingLocationSnapshots(interval: 5)
//            self.startSavingSnapshots(interval: 10)
        }else{
            self.requestPermission()
        }
        
    }
    
    func stopLocationUpdates() {
        self.locationManager.stopUpdatingLocation()
        
        if self.saveSnapshotTimer != nil {
            print("removing saveSnapshotTimer")
            self.saveSnapshotTimer!.invalidate()
        }
    }
    
    func stopListeningToFollowingLocations() {
        for (userId, listener) in Array(self.followingListeners) {
            print("removing following listener of \(userId)")
            
            listener.remove()
            self.followingListeners.removeValue(forKey: userId)
        }
    }
    
    func resetLocationService() {
        self.uncommittedSnapshots = []
        self.stopLocationUpdates()
        self.stopListeningToFollowingLocations()
    }
}
