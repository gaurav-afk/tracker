//
//  ErrorHelper.swift
//  tracker_ios_app
//
//  Created by macbook on 1/3/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

enum AppError: Error, Identifiable {
    var id: Self {self}
    
    case unknown
}

enum LoginError: Error, Identifiable {
    var id: Self {self}
    
    case emptyUsernameOrPwd
    case invalidUser
    case wrongPwd
    case network
    case unknown
}

enum SignUpError: Error,Identifiable {
    var id: Self {self}
    
    case alreadyExist
    case weakPassword
    case confirmPwdNotMatch
    case emptyInputs
    case network
    case unknown
}

enum UserError: Error,Identifiable {
    var id: Self {self}
        
    case cannotBeYourself
    case invalidUser
    case alreadyFollowed
    case notFollowing
    case notFollowedBy
    case databaseError
    case unknown
}

enum UpdateProfileError: Error, Identifiable {
    var id: Self {self}
    
    case emptyNickName
    case imageTooLarge
    case databaseError
    case unknown
}

func translateFirebaseAuthError(error: Error) -> Error? {
    print("translating error \(error), \(error._code), here \(AuthErrorCode.Code(rawValue: error._code))")
    guard let errorCode = AuthErrorCode.Code(rawValue: error._code) else {
        print("unknown error code")
        return AppError.unknown
    }
    
//    let nsError = error as NSError
//    guard let errorCode = AuthErrorCode(rawValue: nsError.code) else {
//        print("Unknown error code")
//        return AppError.unknown
//    }
    
    print("error code is \(errorCode), \(AuthErrorCode.Code.wrongPassword)")
    switch errorCode {
        case AuthErrorCode.Code.userNotFound:
            return LoginError.invalidUser
        case AuthErrorCode.Code.invalidCredential:
            return LoginError.wrongPwd
        case AuthErrorCode.Code.networkError:
            return LoginError.network
        case AuthErrorCode.Code.emailAlreadyInUse:
            return SignUpError.alreadyExist
        case AuthErrorCode.Code.weakPassword:
            return SignUpError.weakPassword
        default:
            return AppError.unknown
    }
}
