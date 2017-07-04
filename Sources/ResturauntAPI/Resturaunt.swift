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

public enum APICollectionError: Error {
    case parseError
    case authError
    case databaseError
}

public class Resturaunt: ResturauntAPI {
    
    private let mongoUrl = "mongodb://kirk:888323@localhost:27017"
    
    // initialize and setup db
    public init() {
        setupDB()
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
    
    
    // add new menu item
    public func addMenuFoodItem(itemType: String, itemSubType: String, itemName: String, itemPrice: Double, imgUrl: String, date: String, completion: @escaping (MenuItem?, Error?) -> Void) {
        
        guard let db = try? connectToDB(), db != nil else {
            Log.error("Could not connect to database")
            completion(nil, APICollectionError.databaseError)
            
            return
        }
        
        let collection = db!["menu_item"]
        
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
}
