//
//  EventItem.swift
//  ResturauntAPI
//
//  Created by Kirk Tautz on 7/4/17.
//
//

import Foundation

public struct EventItem: Item {
    
    // ID
    public let id: String
    
    // The name of the event
    public let name: String
    
    // The date and time of the event
    public let eventDate: String
    
    // The documents created date
    public let date: String
    
    public init(id: String, name: String, eventDate: String, date: String) {
        self.id = id
        self.name = name
        self.eventDate = eventDate
        self.date = date
    }
}

// Make the event item equateble
extension EventItem: Equatable {
    public static func == (lhs:EventItem, rhs:EventItem) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.eventDate == rhs.eventDate && lhs.date == rhs.date
    }
}

// Make extension dictionary convertable
extension EventItem: DictionaryConvertable {
    func toDict() -> JSONDictionary {
        var result = JSONDictionary()
        
        result["id"] = self.id
        result["name"] = self.name
        result["eventDate"] = self.eventDate
        result["date"] = self.date
        
        return result
        
    }
}
