//
//  Constants.swift
//  tracker_ios_app
//
//  Created by macbook on 24/2/2024.
//

import Foundation
import FirebaseFirestore

enum NotificationTypes: Codable {
    case testing  // remove later
    
    case accountCreated
    case invitationReceived
    case invitationSent
    case invitationAccepted
    case invitationRejected
    case subscriberRemoved
}

enum RootViews {
    case main
    case notifications
}

struct UserDefaultsKeys {
    static let REMEMBER_ME = "REMEMBER_ME"
}

struct FireBaseCollections {
    static let COLLECTION_USER_DATA = "User_Data"
}

struct UserDataSubcollections {
    static let COLLECTION_NOTIFICATION = "Notifications"
    static let COLLECTION_WAYPOINT = "WayPoints"
}

struct UserDataFields {
    static let CONNECTION_TIME = "connectionTime"
    static let FOLLOWING = "following"
    static let FOLLOWED_BY = "followedBy"
    static let NICKNAME = "nickName"
    static let PROFILE = "profilePic"
}

struct NotificationFields {
    static let READ = "read"
    static let ACTION_TAKEN = "actionTaken"
}

enum DataChangeType {
    case added
    case updated
    case removed
}

