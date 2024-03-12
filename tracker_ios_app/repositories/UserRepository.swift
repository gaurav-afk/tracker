//
//  UserRepository.swift
//  tracker_ios_app
//
//  Created by macbook on 25/2/2024.
//

import Foundation
import FirebaseFirestore


class UserRepository {
    weak var userRepositoryDelegate: UserRepositoryDelegate?
    private let db: Firestore
    
    init(db : Firestore){
        self.db = db
    }
    
    func listenToUserChanges(userId: String) -> ListenerRegistration {
            let userDocRef = self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userId)
            print("adding listener to user data")
            
            let userListener = userDocRef.addSnapshotListener { docSnapshot, error in
                
                guard let document = docSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                guard let userData = try? document.data(as: UserData.self) else {
                    print("Cannot decode document")
                    return
                }
                print("updating user data")
                self.userRepositoryDelegate?.onUserUpdate(userData: userData)
            }
        
            return userListener
    }
    
    func getUserDataById(userId: String) async throws -> UserData {
        let userData = try await self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userId).getDocument().data(as: UserData.self)
        
        return userData
    }
    
    func createNewUserDataStorage(userId: String, nickName: String = "") async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            print("creating new storage for \(userId), \(UserData().toDictionary())")
            
            do {
                let newUserData = UserData(nickName: nickName)
                let userDocRef = self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userId)
                userDocRef.setData(newUserData.toDictionary()!)
                continuation.resume(returning: ())
            }
            catch let error as NSError {
                print("error is \(error)")
                continuation.resume(throwing: error)
            }
        }
    }
    
    func updateUserData(userId: String, newData: [AnyHashable: Any]) async throws {
        try await self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userId).updateData(newData)
    }

    func updateUserDataInBatch(userIdAndDataTuples: [(String, [AnyHashable: Any])]) async throws {
        guard !userIdAndDataTuples.isEmpty else {
            print("update batch is empty")
            return
        }
        
        let batch = self.db.batch()

        for (userId, newData) in userIdAndDataTuples {
            let docRef = self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userId)
            batch.updateData(newData, forDocument: docRef)
        }

//        batch.commit { err in
//            if let err = err {
//                print("Error writing batch \(err)")
//            } else {
//                print("Batch write succeeded.")
//            }
//        }
        
        try await batch.commit()
        
    }
    
    func isUserExist(userId: String) async -> Bool {
        do {
            let document = try await self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userId).getDocument()
            
            if document.exists {
                print("user exist")
                return true
            } else {
                print("user does not exist")
                return false
            }
        }
        catch let error {
            print("user does not exist: \(error)")
            return false
        }
    }
}
