//
//  UserViewModel.swift
//  tracker_ios_app
//
//  Created by macbook on 24/2/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserViewModel: ObservableObject, UserServiceDelegate {
    private var authenticationService: AuthenticationService
    private var preferenceService: PreferenceService
    private var locationService: LocationService
    private var userService: UserService
    @Published var currentUser: AppUser? = nil
    lazy var rememberMe: Bool? = preferenceService.isRememberLoginStatus
    
    private var userListener: ListenerRegistration? = nil
    private var notificationsListener: ListenerRegistration? = nil
    
    init(authenticationService: AuthenticationService, preferenceService: PreferenceService, userService: UserService, locationService: LocationService){
        self.authenticationService = authenticationService
        self.preferenceService = preferenceService
        self.userService = userService
        self.locationService = locationService
        
//        self.authenticationService.authServiceDelegate = self
        self.userService.userServiceDelegate = self
    }
    
    func onUserInit(user: AppUser) {
        DispatchQueue.main.async {
            print("initializing user \(user.userData?.getUserSummaryDict())")
            self.currentUser = user
        }
    }
    
    func onUserUpdate(userData: UserData) {
        DispatchQueue.main.async {
            print("in user view model updating user data on change")
            self.objectWillChange.send()
            self.currentUser?.userData = userData
        }
    }
    
    func login(email: String, password: String, rememberMe: Bool) async throws {
        guard !email.isEmpty && !password.isEmpty else {
            print("empty username or password")
            throw LoginError.emptyUsernameOrPwd
        }
        
        do {
            try await authenticationService.signIn(email: email, password: password)
            self.preferenceService.isRememberLoginStatus = rememberMe
        }
        catch let error as NSError {
            print("error in login \(error)")
            throw error
        }
    }
    
    func logout() {
        do{
            locationService.resetLocationService()
            try authenticationService.signOut()
            self.currentUser = nil
        }
        catch let err as NSError{
            print(#function, "Unable to sign out the user : \(err)")
        }
    }
    
    func signUp(email: String, nickName: String, password: String, confirmPassword: String) async throws {
        let trimmedNickname = nickName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty && !trimmedNickname.isEmpty && !password.isEmpty && !confirmPassword.isEmpty else {
            print("empty value")
            throw SignUpError.emptyInputs
        }
        guard password == confirmPassword else {
            print("password not match")
            throw SignUpError.confirmPwdNotMatch
        }

        guard password.count >= 8 else {
            throw SignUpError.weakPassword
        }
//        guard !userRepository.getAllUserNames().contains(email) else {
//            print("user already exist")
//            return .failure(SignUpError.alreadyExist)
//        }
        
        guard !(await userService.checkUserExistence(userId: email)) else {
            print("user already exist")
            throw SignUpError.alreadyExist
        }
        
        print("\(#function), \(email), \(password)")
              
        do {
            try await authenticationService.signUp(email: email, nickName: trimmedNickname, password: password)
        }
        catch let error as NSError {
            print("error in sign up \(error)")
            throw error
        }
    }
    
    
    
    func follow(followerId: String, targetId: String) async throws {
        guard !userService.isCurrentUserFollowedBy(userId: followerId) else {
            throw UserError.alreadyFollowed
        }

        do {
            try await userService.follow(followerId: followerId, targetId: targetId)
            
//            if var following = currentUser?.userData?.following {
//                following[targetId] =
//                currentUser?.userData?.following = following
//            }
        }
        catch let error {
            print("error in follow")
            throw error
        }
    }
    
    func unfollow(followerId: String, targetId: String, isRemovingFollower: Bool) async throws {
        guard !isRemovingFollower || userService.isCurrentUserFollowedBy(userId: followerId) else {
            throw UserError.notFollowing
        }

        guard isRemovingFollower || userService.isCurrentUserFollowing(userId: targetId) else {
            throw UserError.notFollowedBy
        }
        
        do {
            try await userService.unfollow(followerId: followerId, targetId: targetId, isRemovingFollower: isRemovingFollower)
            
    //        if var following = currentUser?.userData?.following {
    //            following.removeValue(forKey: targetId)
    //            currentUser?.userData?.following = following
    //        }
        }
        catch let error {
            throw error
        }
    }
    
    
    func updateProfile(userId: String, nickName: String, imageData: Data?) async throws {
        let trimmedNickname = nickName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNickname.isEmpty else {
            print("nick name cannot be empty")
            throw UpdateProfileError.emptyNickName
        }
        
        guard imageData == nil || imageData!.count < 30000 else {
            print("image too large, size \(imageData?.count ?? 0) byte")
            throw UpdateProfileError.imageTooLarge
        }
        
        let base64Encoded = imageData?.base64EncodedString() ?? ""
        print("img string is \(base64Encoded)")
        
        let profilePic: String = base64Encoded 
        
        print("updating profile, \(userId), \(nickName), \(trimmedNickname)")
        
        do {
            try await userService.updateProfile(userId: userId, nickName: trimmedNickname, profilePic: profilePic)
        }
        catch let error {
            throw UpdateProfileError.databaseError
        }
    }
}

