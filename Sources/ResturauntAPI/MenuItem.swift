//
//  MenuItem.swift
//  ResturauntAPI
//
//  Created by Kirk Tautz on 7/3/17.
//
//

import Foundation

public struct MenuItem: Item {
    
    public let id: String
    public let name: String
    public let price: Double
    public let type: String
    public let subType: String
    public let imgUrl: String
    public let date: String
    
    public init(id: String, name: String, price: Double, type: String, subType: String, imgUrl: String, date: String) {
        self.id = id
        self.name = name
        self.price = price
        self.type = type
        self.subType = subType
        self.imgUrl = imgUrl
        self.date = date
    }
    
}

// Make the menu item equateble
extension MenuItem: Equatable {
    public static func == (lhs:MenuItem, rhs:MenuItem) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.price == rhs.price && lhs.type == rhs.type && lhs.subType == rhs.subType && lhs.imgUrl == rhs.imgUrl && lhs.date == rhs.date
    }
}

// Make extension dictionary convertable
extension MenuItem: DictionaryConvertable {
    func toDict() -> JSONDictionary {
        var result = JSONDictionary()

        result["id"] = self.id
        result["itemname"] = self.name
        result["itemtype"] = self.type
        result["itemsubtype"] = self.subType
        result["itemprice"] = self.price
        result["imgurl"] = self.imgUrl
        result["date"] = self.date
        
        return result
        
    }
}

// extension on array to add toDict functionn
extension Array where Element: DictionaryConvertable {
    func toDict() -> [JSONDictionary] {
        return self.map { $0.toDict() }
    }
}

