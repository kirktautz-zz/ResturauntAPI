//
//  User.swift
//  ResturauntAPI
//
//  Created by Kirk Tautz on 7/5/17.
//
//

import Foundation

public struct User {
    
    public let userId: String
    public let username: String
    public let password: String
    public let salt: String
    public let accountType: String
    public let emails: [String]?
    
    public init(userId: String, username: String, password: String, salt: String, accountType: String, emails: [String]?) {
        
        self.userId = userId
        self.username = username
        self.password = password
        self.salt = salt
        self.accountType = accountType
        self.emails = emails
    }
    
}
