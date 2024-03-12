//
//  LocationRepository.swift
//  tracker_ios_app
//
//  Created by macbook on 7/3/2024.
//

import Foundation
import FirebaseFirestore

class LocationRepository {
    weak var locationRepositoryDelegate: LocationRepositoryDelegate?
    private let db: Firestore
    
    init(db : Firestore){
        self.db = db
    }
    
    func listenToLocationChanges(userId: String) -> ListenerRegistration {
            let userDocRef = self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userId)
            print("adding listener to user location data")
            
            let locationListener = userDocRef.collection(UserDataSubcollections.COLLECTION_WAYPOINT).addSnapshotListener { docSnapshot, error in
                    
                guard let snapshot = docSnapshot else{
                    print(#function, "Unable to retrieve data from firestore : \(error)")
                    return
                }
                
                snapshot.documentChanges.forEach{ (docChange) in
                    do{
                        print("location docchange is \(docChange.document.data())")
                        let wayPoint = try docChange.document.data(as: Waypoint.self)
//                        let wayPointId = docChange.document.documentID
        
//                        print("getting notification id \(wayPointId) ")
                        
                        let changeType: DataChangeType
                        switch docChange.type {
                            case .added:
                                changeType = .added
                            case .modified:
                                changeType = .updated
                            case.removed:
                                changeType = .updated
                        }
//                        self.locationRepositoryDelegate?.onLocationChange(type: changeType, wayPointId: wayPointId, wayPoint: wayPoint)
                        self.locationRepositoryDelegate?.onLocationChange(type: changeType, userId: userId, wayPoint: wayPoint)
                        
                    }
                    catch let err as NSError {
                        print(#function, "Unable to convert document into Swift object : \(err)")
//                        throw err
                    }
                }
            }
        
            return locationListener
    }
    
//    func addWaypoints(userId: String, waypoints: [(String, [AnyHashable: Any])]) async throws {
    func addWaypoints(userId: String, waypoints: [(String, Waypoint)]) async throws {
        guard !waypoints.isEmpty else {
            print("waypoints is empty")
            return
        }
        
        print("temporarily disable the firestore waypoints updated")
        
        print("adding  \(waypoints.count) points to db")
        let batch = self.db.batch()
        
        do {
            for (userId, newWaypoint) in waypoints {
                let docRef = self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userId).collection(UserDataSubcollections.COLLECTION_WAYPOINT).document()
                //            batch.setData(newWaypoint as! [String: Any], forDocument: docRef)
                try batch.setData(from: newWaypoint, forDocument: docRef)
            }
            
            try await batch.commit()
        }
        catch let error {
            print("error when adding waypoints to db")
            throw error
        }
    }
}

