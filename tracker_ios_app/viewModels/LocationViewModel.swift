//
//  LocationViewModel.swift
//  tracker_ios_app
//
//  Created by macbook on 7/3/2024.
//

import Foundation
import CoreLocation

class LocationViewModel: ObservableObject, LocationServiceDelegate {
//    @Published var currentLocation: CLLocation
    @Published var currentLocation: Waypoint? = nil
    @Published var locationSnapshots: [Waypoint] = []
    @Published var snapshotsOfFollowings: [String: [Waypoint]] = [:]
    @Published var currentWeather: Weather? = nil
    private var locationService: LocationService
    private var weatherService: WeatherService
    
    
//    init(currentLocation: CLLocation, locationSnapshots: [Waypoint], snapshotsOfFollowings: [String : [Waypoint]], locationService: LocationService) {
    init(locationService: LocationService, weatherService: WeatherService) {
//        self.currentLocation = currentLocation
//        self.locationSnapshots = locationSnapshots
//        self.snapshotsOfFollowings = snapshotsOfFollowings
        self.locationService = locationService
        self.weatherService = weatherService
        
        self.locationService.locationServiceDelegate = self
        print("after loc view model init")
    }
    
//    func onSelfLocationUpdated(locations: [CLLocation]) {
    func onSelfLocationUpdated(waypoints: [Waypoint]) {
        print("before self location updated")
        
        self.locationSnapshots.append(contentsOf: waypoints)
        
        if waypoints.last != nil{
            //most recent
//            print(#function, "most recent location : \(waypoints.last!)")
            
            self.currentLocation = waypoints.last!
        }else{
            //oldest known location
//            print(#function, "last known location : \(waypoints.first)")
            
            self.currentLocation = waypoints.first!
        }
    }
    
    func onLocationAdded(userId: String, waypoint: Waypoint) {
        print("before adding location, \(userId), \(waypoint)")
        if var waypoints = self.snapshotsOfFollowings[userId] {
            waypoints.append(waypoint)
            self.snapshotsOfFollowings[userId] = waypoints
        }
        print("after adding location")
    }
    
    
    func onLocationInit(userId: String) {
        print("initing following in locationview model")
        self.snapshotsOfFollowings[userId] = []
    }
    
    func startLocationUpdates() {
        print("before start location update")
        locationService.startLocationUpdates()
        print("after start location update")
    }
    
    func startSavingSnapshots(userId: String) {
        print("before start saving snapshots")
        locationService.startSavingSnapshots(userId: userId, interval: 10)
        print("after start saving snapshots")
    }
    
    func getLocationDetails(latitude: Double, longitude: Double) async {
        do {
            self.currentWeather = try await weatherService.getWeatherFromAPI(latitude: latitude, longitude: longitude)
        }
        catch let error {
            print("cannot get weather \(error)")
        }
    }
}
