//
//  Notification.swift
//  tracker_ios_app
//
//  Created by macbook on 25/2/2024.
//

import Foundation
import FirebaseFirestore

struct Notification: Codable, Identifiable {
    @DocumentID var id: String?
    let title: String
    var content: String
    let type: NotificationTypes
    var read: Bool
    var extraData: [String: String] = [:]
    let time: Date
    var actionTaken: Bool? = nil
    
    // for preview testing
    init(){
        self.title = "Testing"
        self.content = "content"
        self.type = .accountCreated
        self.read = false
        self.time = Date.now
    }
    
    init(type: NotificationTypes, extraData: [String: String] = [:]){
        self.read = false
        self.type = type
        self.extraData = extraData
        self.time = Date.now
        
        switch type {
            case .accountCreated:
                self.title = "Account Created"
                self.content = "Welcome to our app."
            case .invitationAccepted:
                self.title = "Invitation Accepted"
                self.content = "User \\(target) accepted your follow request."
            case .invitationReceived:
                self.title = "Invitation Received"
                self.content = "User \\(follower) request to follow you."
                self.actionTaken = false
            case .invitationRejected:
                self.title = "Invitation Rejected"
                self.content = "User \\(target) rejected your follow request."
            case .invitationSent:
                self.title = "Invitation Sent"
                self.content = "pending for user \\(target) to accept your follow request."
            case .subscriberRemoved:
                self.title = "Follow Permission Removed"
                self.content = "User \\(target) has removed you from the follower list."
            case .testing:
                self.title = "testing"
                self.content = "Remove this later"
            default:
                self.title = "unknown"
                self.content = "unknown message"
        }
        
        for key in extraData.keys {
            print("replacing kkey \(key)")
            self.content = self.content.replacingOccurrences(of: "\\(\(key))", with: extraData[key]!)
        }
        
    }
}

