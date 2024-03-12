//
//  Extensions.swift
//  tracker_ios_app
//
//  Created by macbook on 25/2/2024.
//

import Foundation

extension Encodable {
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}

//extension CastableError {
//    func cast<T: CastableError, U: CastableError>(error: T) -> U {
//        if let error = error as? AppError {
//            print("can be casted to app error")
//            return .unknown
//        }
//        else {
//            return error
//        }
//    }
//    
//}
