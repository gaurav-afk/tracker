//
//  NotificationService.swift
//  tracker_ios_app
//
//  Created by macbook on 25/2/2024.
//

import Foundation


class NotificationService: NotificationRepositoryDelegate {
    weak var notificationServiceDelegate: NotificationServiceDelegate?
    private var notificationRepository: NotificationRepository
    
    init(notificationRepository: NotificationRepository){
        self.notificationRepository = notificationRepository
        
        self.notificationRepository.notificationRepositoryDelegate = self
    }
    
    func onNotificationChange(type: DataChangeType, notificationId: String, notification: Notification) {
        print("in notification service update on change")
        switch type {
            case .added:
                notificationServiceDelegate?.onNotificationAdded(notificationId: notificationId, notification: notification)
            case .updated:
                notificationServiceDelegate?.onNotificationUpdated(notificationId: notificationId, notification: notification)
            case .removed:
                notificationServiceDelegate?.onNotificationRemoved(notificationId: notificationId, notification: notification)
        }
    }
    
    func notificationRead(userId: String, notificationId: String) {
        notificationRepository.updateNotification(userId: userId, notificationId: notificationId, newData: [NotificationFields.READ: true])
    }
    
    func sendNotification(receiverId: String, notification: Notification) {
        notificationRepository.createNotification(receiverId: receiverId, notification: notification)
    }
    
    func sendNewAccountNotification(receiverId: String) {
        do{
            let newAccountNotification = Notification(type: .accountCreated)
            
            self.sendNotification(receiverId: receiverId, notification: newAccountNotification)
        }
        catch let err as NSError{
            print(#function, "Unable to add document to firestore : \(err)")
        }
    }

    func sendRequestReceivedNotification(receiverId: String, target: String) {
        do{
            let notification = Notification(type: .invitationReceived, extraData: ["follower": target])
            
            self.sendNotification(receiverId: receiverId, notification: notification)
        }
        catch let err as NSError{
            print(#function, "Unable to add document to firestore : \(err)")
        }
    }
    
    func sendRequestSentNotification(receiverId: String, by: String) {
        do{
            let followerNotification = Notification(type: .invitationSent, extraData: ["target": by])
            
            self.sendNotification(receiverId: receiverId, notification: followerNotification)
        }
        catch let err as NSError{
            print(#function, "Unable to add document to firestore : \(err)")
        }
    }
    
    func sendAcceptedNotification(receiverId: String, by: String) {
        do{
            let notification = Notification(type: .invitationAccepted, extraData: ["target": by])
            self.sendNotification(receiverId: receiverId, notification: notification)
        }
        catch let err as NSError{
            print(#function, "Unable to add document to firestore : \(err)")
        }
    }
    
    func sendRejectedNotification(receiverId: String, by: String) {
        do{
            let notification = Notification(type: .invitationRejected, extraData: ["target": by])
            self.sendNotification(receiverId: receiverId, notification: notification)
        }
        catch let err as NSError{
            print(#function, "Unable to add document to firestore : \(err)")
        }
    }
    
    func sendRemovedNotification(receiverId: String, by: String) {
        do{
            let notification = Notification(type: .subscriberRemoved, extraData: ["target": by])
            self.sendNotification(receiverId: receiverId, notification: notification)
        }
        catch let err as NSError{
            print(#function, "Unable to add document to firestore : \(err)")
        }
    }
    
    func actionDone(userId: String, notificationId: String) {
        notificationRepository.updateNotification(userId: userId, notificationId: notificationId, newData: [NotificationFields.ACTION_TAKEN: true])
    }
    
    func testing(receiverId: String) {
        do{
            let notification = Notification(type: .testing)
            self.sendNotification(receiverId: receiverId, notification: notification)
        }
        catch let err as NSError{
            print(#function, "Unable to add document to firestore : \(err)")
        }
    }
}
