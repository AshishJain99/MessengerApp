//
//  DatabaseManager.swift
//  MessengerApp
//
//  Created by sixpep on 26/02/23.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    

}
//MARK: - Account Management
extension DatabaseManager{
    
    public func userExists(with email:String, completion: @escaping((Bool)->Void)){
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else{
               completion(false)
                return
            }
            completion(true)
        }
        
    }
    
    /// Insert new user to database
    public func inserUser(with user: ChatAppUser){
        database.child(user.safeEmail).setValue([
            "Name":user.Name
        ])
    }
    
}

struct ChatAppUser{
    let Name:String
    let emailAddress:String
    
    var safeEmail:String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
//    let profilePictureUel: String
}
