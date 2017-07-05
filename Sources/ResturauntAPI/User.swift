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
    public let createdAt: String
    
    public init(userId: String, username: String, password: String, salt: String, accountType: String, emails: [String]?, createdAt: String) {
        
        self.userId = userId
        self.username = username
        self.password = password
        self.salt = salt
        self.accountType = accountType
        self.emails = emails
        self.createdAt = createdAt
    }
    
}

extension User: DictionaryConvertable {
    func toDict() -> JSONDictionary {
        var result = JSONDictionary()
        
        result["id"] = self.userId
        result["username"] = self.username
        result["password"] = self.password
        result["accounttype"] = self.accountType
        result["salt"] = self.salt
        result["createdat"] = self.createdAt
        result["emails"] = self.emails
        
        return result
        
    }
}

