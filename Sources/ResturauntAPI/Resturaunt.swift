//
//  Resturaunt.swift
//  ResturauntAPI
//
//  Created by Kirk Tautz on 7/4/17.
//
//

import Foundation
import SwiftyJSON
import LoggerAPI
import MongoKitten
import Credentials
import CredentialsHTTP
import Cryptor

public enum APICollectionError: Error {
    case parseError
    case authError
    case databaseError
}

public class Resturaunt: ResturauntAPI {
    
    private let mongoUrl = "mongodb://localhost:27017"
    public let credentials = Credentials()
    public let userCredentials = Credentials()
    
    // initialize and setup db
    public init() {
        setupDB()
        setupAuth()
    }
    
    // setup basic auth
    func setupAuth() {
        
        // Create plugin for Basic Auth
        let basicCreds = CredentialsHTTPBasic(verifyPassword: { userId, password, callback in
            
            // Get all users from database
            self.getAllUsers(completion: { (users, error) in
                guard error == nil else {
                    Log.error("Error getting users")
                    return
                }
                
                // unwrap and loop through users
                if let users = users {
                    
                    for user in users {
                        if user.username == userId {
                            
                            // When a name matches, check it's password
                            if let result = try? user.password.verifyPassword(password, user.salt) {
                                
                                // if the password is correct, break the loop
                                if result {
                                    callback(UserProfile(id: user.userId, displayName: user.username, provider: "Resturaunt"))
                                    Log.info("Welcome \(user.username)")
                                    
                                    break
                                } else {
                                    Log.warning("Invalid password")
                                }
                            }
                        } else {
                            Log.warning("Username not found")
                        }
                    }
                } else {
                    Log.error("Could not unwrap data from database")
                }
            })
            
            callback(nil)
        }, realm: "Users")
        
        // TODO: - create admin authentication
        
//        let adminCreds = CredentialsHTTPBasic(verifyPassword: { userId, password, callback in
//            
//            // Get all users from database
//            self.getAllUsers(completion: { (users, error) in
//                guard error == nil else {
//                    Log.error("Error getting users")
//                    return
//                }
//                
//                // unwrap and loop through users
//                if let users = users {
//                    
//                    for user in users {
//                        if user.username == userId {
//                            
//                            // When a name matches, check it's password
//                            if let result = try? user.password.verifyPassword(password, user.salt) {
//                                
//                                // if the password is correct, break the loop
//                                if result {
//                                    callback(UserProfile(id: user.userId, displayName: user.username, provider: "Resturaunt"))
//                                    Log.info("Welcome \(user.username)")
//                                    
//                                    break
//                                } else {
//                                    Log.warning("Invalid password")
//                                }
//                            }
//                        } else {
//                            Log.warning("Username not found")
//                        }
//                    }
//                } else {
//                    Log.error("Could not unwrap data from database")
//                }
//            })
//            
//            callback(nil)
//        }, realm: "Users")
        
        credentials.register(plugin: basicCreds)
    }
    
    
    
    // Check connection to MongoDB is successful
    private func setupDB() {
        do {
            _ = try connectToDB()
            Log.info("Successfully setup database")
        } catch {
            Log.error("Could not setup database")
        }
    }
    
    // Connect to MongoDB to use database
    private func connectToDB() throws -> Database? {
        Log.info("Establishing connection to MongoDB database")
        
        do {
            
            let server = try Server(mongoUrl)
            let db = server["dev"]
            
            Log.info("Connected to database")
            return db
        } catch {
            Log.error("Could not connect to the database")
            return nil
        }
    }
    
    // MARK: - Protocol methods
    
    // get all menu items
    public func getMenuItems(completion: @escaping ([MenuItem]?, Error?) -> Void) {
        
        guard let db = try? connectToDB(), db != nil else {
            Log.error("Could not connect to database")
            completion(nil, APICollectionError.databaseError)
            
            return
        }
        
        let collection = db!["menu_item"]
        
        do {
            let recievedItems = try collection.find()
            
            var itemsArr = [MenuItem]()
            for item in recievedItems {
                if let id = String(item["_id"]), let name = String(item["itemname"]), let price = Double(item["itemprice"]), let type = String(item["itemtype"]), let subType = String(item["itemsubtype"]), let imgUrl = String(item["imgurl"]), let date = String(item["date"]) {
                    
                    let newItem = MenuItem(id: id, name: name, price: price, type: type, subType: subType, imgUrl: imgUrl, date: date)
                    
                    itemsArr.append(newItem)
                } else {
                    completion(nil, APICollectionError.parseError)
                    Log.warning("Could not get values from document")
                }
                
            }
            
            completion(itemsArr, nil)
            
        } catch {
            Log.error("Could not perform db fetch")
            completion(nil, APICollectionError.databaseError)
        }
        
        
    }
    
    // Get specific menu item
    public func getMenuItem(id: String, completion: @escaping (MenuItem?, Error?) -> Void){
        
        guard let db = try? connectToDB(), db != nil else {
            Log.error("Could not connect to database")
            completion(nil, APICollectionError.databaseError)
            
            return
        }
        
        let collection = db!["menu_item"]
        
        do {
            
            let objectId = try ObjectId(id)
            let retrievedMenuItem = try collection.findOne("_id" == objectId)
            
            if let retrievedMenuItem = retrievedMenuItem {
                if let name = String(retrievedMenuItem["itemname"]), let price = Double(retrievedMenuItem["itemprice"]), let type = String(retrievedMenuItem["itemtype"]), let subType = String(retrievedMenuItem["itemsubtype"]), let imgUrl = String(retrievedMenuItem["imgurl"]), let date = String(retrievedMenuItem["date"]) {
                    
                    let menuItem = MenuItem(id: id, name: name, price: price, type: type, subType: subType, imgUrl: imgUrl, date: date)
                    completion(menuItem, nil)
                } else {
                    completion(nil, APICollectionError.parseError)
                }
            }
        } catch {
            completion(nil, APICollectionError.databaseError)
        }
    }
    
    // add new menu item
    public func addMenuFoodItem(itemType: String, itemSubType: String, itemName: String, itemPrice: Double, imgUrl: String, completion: @escaping (MenuItem?, Error?) -> Void) {
        
        guard let db = try? connectToDB(), db != nil else {
            Log.error("Could not connect to database")
            completion(nil, APICollectionError.databaseError)
            
            return
        }
        
        let collection = db!["menu_item"]
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let date = formatter.string(from: Date())
        
        let document: Document = [
            "itemtype" : itemType,
            "itemsubtype" : itemSubType,
            "itemname" : itemName,
            "itemprice" : itemPrice,
            "imgurl" : imgUrl,
            "date" : date
        ]
        
        do {
            let id = try collection.insert(document)
            
            if let id = String(id) {
                let menuItem = MenuItem(id: id, name: itemName, price: itemPrice, type: itemType, subType: itemSubType, imgUrl: imgUrl, date: date)
                
                completion(menuItem, nil)
                Log.info("Successfully added document")
            } else {
                Log.error("Did not retrieve ID")
            }
        } catch {
            Log.warning("Could not add document")
        }
        
    }
    
    // edit an existing menu item. If values are nil, the saved data will be used
    public func editMenuFoodItem(id: String, itemType: String?, itemSubType: String?, itemName: String?, itemPrice: Double?, imgUrl: String?, completion: @escaping (MenuItem?, Error?) -> Void) {
        guard let db = try? connectToDB(), db != nil else {
            Log.error("Could not connect to database")
            completion(nil, APICollectionError.databaseError)
            
            return
        }
        
        let collection = db!["menu_item"]
        
        do {
            
            let objectId = try ObjectId(id)
            let query: Query = "_id" == objectId
            
            if let result = try collection.findOne(query) {
                guard let dbName = String(result["itemname"]), let dbPrice = Double(result["itemprice"]), let dbType = String(result["itemtype"]), let dbSubType = String(result["itemsubtype"]), let dbImgUrl = String(result["imgurl"]) else {
                    Log.error("Document data is incomplete")
                    completion(nil, APICollectionError.databaseError)
                    return
                }
                
                let name = itemName ?? dbName
                let type = itemType ?? dbType
                let subType = itemSubType ?? dbSubType
                let price = itemPrice ?? dbPrice
                let img = imgUrl ?? dbImgUrl
                
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .medium
                let date = formatter.string(from: Date())
                
                let updatedDocumet: Document = [
                    "itemtype" : type,
                    "itemsubtype" : subType,
                    "itemname" : name,
                    "itemprice" : price,
                    "imgurl" : img,
                    "date" : date
                ]
                
                try collection.update("_id" == objectId, to: updatedDocumet)
                let menuItem = MenuItem(id: id, name: name, price: price, type: type, subType: subType, imgUrl: img, date: date)
                completion(menuItem, nil)
                
            } else {
                Log.error("Could not unwrap result")
                completion(nil, APICollectionError.databaseError)
            }
            
        } catch {
            Log.error("Could not find document")
        }
    }
    
    // delete menu item
    public func deleteMenuItem(id: String, completion: @escaping (Error?) -> Void) {
        guard let db = try? connectToDB(), db != nil else {
            Log.error("Could not connect to database")
            completion(APICollectionError.databaseError)
            
            return
        }
        
        let collection = db!["menu_item"]
        
        do {
            let objectId = try ObjectId(id)
            try collection.remove("_id" == objectId)
            completion(nil)
        } catch {
            Log.warning("Could not remove object")
            completion(APICollectionError.databaseError)
        }
        
    }
    
    // Delete all items
    public func clearMenuItems(completion: (Error?) -> Void) {
        
        guard let db = try? connectToDB(), db != nil else {
            Log.error("Could not connect to database")
            completion(APICollectionError.databaseError)
            
            return
        }
        
        let collection = db!["menu_item"]
        do {
            let docs = try collection.find()
            
            for doc in docs {
                try collection.remove("_id" == doc["_id"])
            }
            
            Log.info("Cleared all documents")
            completion(nil)
        } catch {
            Log.warning("Could not remove documents")
            completion(APICollectionError.databaseError)
        }
    }
    
    // get items by type
    public func getItemsByType(type: String, subType: String?, completion: @escaping ([MenuItem]?, Error?) -> Void){
        
        guard let db = try? connectToDB(), db != nil else {
            Log.error("Could not connect to database")
            completion(nil, APICollectionError.databaseError)
            
            return
        }
        
        let collection = db!["menu_item"]
        
        let query: Query
        
        if subType != nil {
            query = "itemsubtype" == subType
        } else {
            query = "itemtype" == type
        }
        
        do {
            let retResults = try collection.find(query)
            
            var itemsArr = [MenuItem]()
            for item in retResults {
                if let id = String(item["_id"]), let name = String(item["itemname"]), let price = Double(item["itemprice"]), let type = String(item["itemtype"]), let subType = String(item["itemsubtype"]), let imgUrl = String(item["imgurl"]), let date = String(item["date"]) {
                    
                    let newItem = MenuItem(id: id, name: name, price: price, type: type, subType: subType, imgUrl: imgUrl, date: date)
                    
                    itemsArr.append(newItem)
                } else {
                    completion(nil, APICollectionError.parseError)
                    Log.warning("Could not get values from document")
                }
                
            }
            
            completion(itemsArr, nil)
            
        } catch {
            
        }
    }
    
    // Count of all menu items
    public func countMenuItems(completion: @escaping (Int?, Error?) ->Void) {
        guard let db = try? connectToDB(), db != nil else {
            Log.error("Could not connect to database")
            completion(nil, APICollectionError.databaseError)
            
            return
        }
        
        let collection = db!["menu_item"]
        
        do {
            let results = try collection.find()
            let count = try results.count()
            
            Log.info("query return \(count) items")
            completion(count, nil)
        } catch {
            Log.error("Could not get count")
            completion(nil, APICollectionError.databaseError)
            
        }
    }
    
    // MARK: - User mothds
    
    // get all users
    public func getAllUsers(completion: @escaping ([User]?, Error?) -> Void) {
        
        guard let db = try? connectToDB(), db != nil else {
            Log.error("Could not connect to database")
            completion(nil, APICollectionError.databaseError)
            
            return
        }
        
        let collection = db!["users"]
        
        do {
            Log.info("Searching for users")
            let results = try collection.find()
            
            var users = [User]()
            
            for user in results {
                if let userId = String(user["_id"]), let username = String(user["username"]), let password = String(user["password"]), let salt = String(user["salt"]), let accountType = String(user["accounttype"]), let createdAt = String(user["createdat"]) {
                    
                    var emails: [String]?
                    
                    if let possibleEmails = Array(user["emails"]) as? [String] {
                        emails = possibleEmails
                    }
                    
                    let newUser = User(userId: userId, username: username, password: password, salt: salt, accountType: accountType, emails: emails, createdAt: createdAt)
                    
                    users.append(newUser)
                    
                }
            }
            
            completion(users, nil)
            
        } catch {
            Log.warning("could not get users")
        }
        
    }
    
    // create a new user
    public func addUser(username: String, password: String, emails: [String]?, completion: (User?, Error?) -> Void) {
        guard let db = try? connectToDB(), db != nil else {
            Log.error("Could not connect to database")
            
            return
        }
        
        let collection = db!["users"]
        
        var userDoc = Document()
        
        if username == "" {
            Log.warning("Username cannot be blank")
            completion(nil, APICollectionError.parseError)
        } else {
            userDoc["username"] = username
            
            let salt = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            
            let hashedPass = hashPassword(from: password, salt: salt)
            userDoc["password"] = hashedPass
            userDoc["accounttype"] = "client"
            userDoc["emails"] = emails
            userDoc["salt"] = salt
            
            let formatter = DateFormatter()
            let date = formatter.string(from: Date())
            
            userDoc["createdat"] = date
            
            do {
                let objectId = try collection.insert(userDoc)
                
                guard let userId = String(objectId) else {
                    completion(nil, APICollectionError.databaseError)
                    return
                }
                
                let newUser = User(userId: userId, username: username, password: hashedPass, salt: salt, accountType: "client", emails: emails, createdAt: date)
                completion(newUser, nil)
                
            } catch {
                completion(nil, APICollectionError.databaseError)
            }
            
            
        }

    }
}

// helper function to hash password
func hashPassword(from str: String, salt: String) -> String {
    let key = PBKDF.deriveKey(fromPassword: str, salt: salt, prf: .sha512, rounds: 250_000, derivedKeyLength: 64)
    
    return CryptoUtils.hexString(from: key)
}

// Extension on string to verify password
extension String {
    func verifyPassword(_ pass: String, _ salt: String) throws -> Bool {
        
        let key = PBKDF.deriveKey(fromPassword: pass, salt: salt, prf: .sha512, rounds: 250_000, derivedKeyLength: 64)
        
        let hashedPass = CryptoUtils.hexString(from: key)
        
        if self == hashedPass {
            return true
        } else {
            return false
        }
        
    }
}
