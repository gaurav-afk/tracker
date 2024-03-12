//
//  AuthenticationService.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class AuthenticationService {
    weak var authServiceDelegate: AuthServiceDelegate?
    weak var notificationInitDelegate: NotificationInitDelegate?
    private var preferenceService: PreferenceService
    private var notificationService: NotificationService
    private var userRepository: UserRepository
    private var notificationRepository: NotificationRepository
    private var userListener: ListenerRegistration? = nil
    private var notificationsListener: ListenerRegistration? = nil
//    private var currentUser: AppUser? = nil
    
    init(preferenceService: PreferenceService, notificationService: NotificationService, userRepository: UserRepository, notificationRepository: NotificationRepository) {
        self.preferenceService = preferenceService
        self.notificationService = notificationService
        self.userRepository = userRepository
        self.notificationRepository = notificationRepository
    }
    
    func signUp(email : String, nickName: String, password : String) async throws {
        do {
            let userAccount = try await self.createAccount(email: email, password: password)
            
            if let identifier = userAccount.email ?? userAccount.phoneNumber {
                try await userRepository.createNewUserDataStorage(userId: identifier, nickName: nickName)
                notificationService.sendNewAccountNotification(receiverId: identifier)
//                self.currentUser = AppUser(accountData: userAccount, userData: UserData(nickName: nickName))
                print("current user is \(identifier)")
                self.initializeData(user: AppUser(accountData: userAccount, userData: UserData(nickName: nickName)))
            }
        }
        catch let error as NSError {
            print("error in sign up \(error)")
            throw error
        }
    }
    
    func createAccount(email : String, password : String) async throws -> User {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<User, Error>) in
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                if let error = error as? NSError {
                    print("sign in error is \(error)")
                    continuation.resume(throwing: error)
                    return
                }
                
                switch authResult{
                    case .none:
                        print(#function, "Unable to create the account")
                        continuation.resume(throwing: SignUpError.unknown)
                    case .some(_):
                        if let userAccount = authResult?.user {
                            continuation.resume(returning: authResult!.user)
                        }
                }
                
            }
        }
    }
    
    func signIn(email : String, password : String) async throws {

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
//                if let error = error as? NSError {
//                    print("sign in error is \(error)")
//                    continuation.resume(throwing: error)
//                    return
//                }
                if let error = error, let customError = translateFirebaseAuthError(error: error) {
                    print("sign in error is \(customError)")
                    continuation.resume(throwing: customError)
                    return
                }
                
                switch authResult{
                    case .none:
                        print(#function, "Unable to sign in")
                        continuation.resume(throwing: LoginError.unknown)
                    case .some(_):
                        print(#function, "Login Successful")
                        
                        if let userAccount = authResult?.user {
//                            self!.currentUser = AppUser(accountData: userAccount)
                            
                            self!.initializeData(user: AppUser(accountData: userAccount))

                        }
                        continuation.resume(returning: ())
                }
            }
        }
    }
    
    func signOut() throws {
        do{
            try Auth.auth().signOut()
            self.resetListeners()
        }
        catch let err as NSError{
            print(#function, "Unable to sign out the user : \(err)")
            throw err
        }
    }
    
    func initializeData(user: AppUser) {
        print("initializing data")
        self.resetListeners()
        
        self.authServiceDelegate?.onUserInit(user: user)
        self.notificationInitDelegate?.onNotificationInit()
        print("here 0")
        self.userListener = self.userRepository.listenToUserChanges(userId: user.identifier)
        print("here 1")
        self.notificationsListener = self.notificationRepository.listenToNotificationChanges(userId: user.identifier)
        print("init data done")
    }
    
    func resetListeners() {
        print("resetting listeners")
        if self.userListener != nil {
            self.userListener?.remove()
            self.userListener = nil
        }
        
        if self.notificationsListener != nil {
            self.notificationsListener?.remove()
            self.notificationsListener = nil
        }
    }
}
