//
//  UserService.swift
//  tracker_ios_app
//
//  Created by macbook on 29/2/2024.
//

import Foundation
import FirebaseFirestore

class UserService: UserRepositoryDelegate, AuthServiceDelegate, UserDataValidationDelegate {
    weak var userServiceDelegate: UserServiceDelegate?
    weak var updateFollowingLocationsDelegate: UpdateFollowingLocationsDelegate?
    private var authenticationService: AuthenticationService
    private var userRepository: UserRepository
    private var notificationService: NotificationService
    var currentUser: AppUser? = nil
    
    init(userRepository: UserRepository, authenticationService: AuthenticationService, notificationService: NotificationService) {
        self.userRepository = userRepository
        self.authenticationService = authenticationService
        self.notificationService = notificationService
        
        self.userRepository.userRepositoryDelegate = self
        self.authenticationService.authServiceDelegate = self
    }

    
    func onUserInit(user: AppUser) {
        print("in auth service update user on change")
        self.currentUser = user
        userServiceDelegate?.onUserInit(user: user)
//        updateFollowingLocationsDelegate?.onFollowerUpdated(userId: user.identifier)
        if let userData = self.currentUser?.userData {
            updateFollowingLocationsDelegate?.onFollowerUpdated(userData: userData)
        }
    }
    
    func onUserUpdate(userData: UserData) {
        print("in auth service update user on change")
        self.currentUser?.userData = userData
        userServiceDelegate?.onUserUpdate(userData: userData)
        
        if let userData = self.currentUser?.userData {
//            updateFollowingLocationsDelegate?.onFollowerUpdated(userId: user.identifier)
            updateFollowingLocationsDelegate?.onFollowerUpdated(userData: userData)
        }
    }
    
    func follow(followerId: String, targetId: String) async throws {
        let followerUserData: UserData = try await userRepository.getUserDataById(userId: followerId)
        
        let connectAt: Date = Date.now
        
        var followerInfoDict: [String: Any] = followerUserData.getUserSummaryDict()
        var targetInfoDict: [String: Any] = currentUser!.userData!.getUserSummaryDict()
        
        followerInfoDict[UserDataFields.CONNECTION_TIME] = connectAt
        targetInfoDict[UserDataFields.CONNECTION_TIME] = connectAt
        
        // use FieldPath to make Firebase to correctly treat a dot as part of the email instead of the next position in the path
        var userIdAndDataTuples: [(String, [AnyHashable: Any])] = []
        userIdAndDataTuples.append((followerId, [FieldPath([UserDataFields.FOLLOWING, targetId]): targetInfoDict]))
        userIdAndDataTuples.append((targetId, [FieldPath([UserDataFields.FOLLOWED_BY, followerId]): followerInfoDict]))

        do {
            try await userRepository.updateUserDataInBatch(userIdAndDataTuples: userIdAndDataTuples)
            notificationService.sendAcceptedNotification(receiverId: followerId, by: targetId)
        }
        catch let error {
            print("error in updating db in follow \(error)")
            throw error
        }
    }
    
    func unfollow(followerId: String, targetId: String, isRemovingFollower: Bool) async throws {
        // use FieldPath to make Firebase to correctly treat a dot as part of the email instead of the next position in the path
        var userIdAndDataTuples: [(String, [AnyHashable: Any])] = []
        userIdAndDataTuples.append((followerId, [FieldPath([UserDataFields.FOLLOWING, targetId]): FieldValue.delete()]))
        userIdAndDataTuples.append((targetId, newData: [FieldPath([UserDataFields.FOLLOWED_BY, followerId]): FieldValue.delete()]))

        do {
            try await userRepository.updateUserDataInBatch(userIdAndDataTuples: userIdAndDataTuples)
            
            if isRemovingFollower {
                notificationService.sendRemovedNotification(receiverId: followerId, by: targetId)
            }
        }
        catch let error {
            print("error in updating db in unfollow \(error)")
            throw error
        }
    }
    
    // when a user updates his profile, the latest profile will be stored into the following field of all of his followers. Here, we don't choose the approach of getting the user profile at the time of loading the following list, because it will take for database operations
    func updateProfile(userId: String, nickName: String, profilePic: String) async throws {
        let following = self.currentUser?.userData?.following.keys.map {$0} ?? []
        let followers = self.currentUser?.userData?.followedBy.keys.map {$0} ?? []
        
        // update self profile pic
        var userIdAndDataTuples: [(String, [AnyHashable: Any])] = [(userId, [UserDataFields.NICKNAME: nickName, UserDataFields.PROFILE: profilePic])]
        
        // notify users that the current user follows or is followed by the current user that the profile is changing
        for follower in followers {
            print("in batch follower: \(follower)")
        
            userIdAndDataTuples.append((follower, [FieldPath([UserDataFields.FOLLOWING, userId, UserDataFields.NICKNAME]): nickName, FieldPath([UserDataFields.FOLLOWING, userId, UserDataFields.PROFILE]): profilePic]))
        }
        
        for follow in following {
            print("in batch follow: \(follow)")
        
            userIdAndDataTuples.append((follow, [FieldPath([UserDataFields.FOLLOWED_BY, userId, UserDataFields.NICKNAME]): nickName, FieldPath([UserDataFields.FOLLOWED_BY, userId, UserDataFields.PROFILE]): profilePic]))
        }
        
        do {
            try await userRepository.updateUserDataInBatch(userIdAndDataTuples: userIdAndDataTuples)
        }
        catch let error {
            print("cannot update in batch: \(error)")
            throw error
        }
    }
    
    func isCurrentUserFollowing(userId: String) -> Bool {
        if self.currentUser!.userData!.following.keys.contains(userId) {
            print("already following")
            return true
        }
        print("not already following")
        return false
    }
    
    func isCurrentUserFollowedBy(userId: String) -> Bool {
        if self.currentUser!.userData!.followedBy.keys.contains(userId) {
            print("already followed by")
            return true
        }
        print("not already followed by")
        return false
    }
    
    func checkUserExistence(userId: String) async -> Bool {
        return await userRepository.isUserExist(userId: userId)
    }
}
