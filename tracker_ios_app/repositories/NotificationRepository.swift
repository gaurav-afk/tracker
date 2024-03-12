//
//  NotificationRepository.swift
//  tracker_ios_app
//
//  Created by macbook on 26/2/2024.
//

import Foundation
import FirebaseFirestore


class NotificationRepository {
    weak var notificationRepositoryDelegate: NotificationRepositoryDelegate?
    private let db: Firestore
    
    init(db : Firestore){
        self.db = db
    }
    
    func listenToNotificationChanges(userId: String) -> ListenerRegistration {
        let userDocRef = self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userId)
        
        let notificationListener = userDocRef.collection(UserDataSubcollections.COLLECTION_NOTIFICATION).addSnapshotListener { querySnapshot, error in
            print("adding listener to notifications")
            
            guard let snapshot = querySnapshot else{
                print(#function, "Unable to retrieve data from firestore : \(error)")
                return
            }
            
            snapshot.documentChanges.forEach{ (docChange) in
                do{
                    let notification = try docChange.document.data(as: Notification.self)
                    let notificationId = docChange.document.documentID
    
                    print("getting notification id \(notificationId) ")
                    
                    let changeType: DataChangeType
                    switch docChange.type {
                        case .added:
                            changeType = .added
                        case .modified:
                            changeType = .updated
                        case.removed:
                            changeType = .updated
                    }
                    self.notificationRepositoryDelegate?.onNotificationChange(type: changeType, notificationId: notificationId, notification: notification)
                    
                }
                catch let err as NSError {
                    print(#function, "Unable to convert document into Swift object : \(err)")
                }
            }
        }
        
        return notificationListener
    }
    
    func createNotification(receiverId: String, notification: Notification) {
        do {
            try self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(receiverId).collection(UserDataSubcollections.COLLECTION_NOTIFICATION).addDocument(from: notification)
        }
        catch let error as NSError {
            print("error in sending notification \(error)")
        }
    }
    
    func updateNotification(userId: String, notificationId: String, newData: [String: Any]) {
        self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userId).collection(UserDataSubcollections.COLLECTION_NOTIFICATION).document(notificationId).updateData(newData)
    }
}
