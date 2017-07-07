//
//  ResturauntController.swift
//  ResturauntAPI
//
//  Created by Kirk Tautz on 7/4/17.
//
//

import Foundation
import Kitura
import HeliumLogger
import LoggerAPI
import SwiftyJSON

public final class ResturauntController {
    public let rest: ResturauntAPI
    public let router = Router()
    public let port = 8090
    public let menuItemsPath = "api/v1/menu_items"
    public let eventItemsPath = "api/v1/event_items"
    
    public init(backend: ResturauntAPI) {
        self.rest = backend
        routerSetup()
        
    }
    
    // MARK: - Routes
    public func routerSetup() {
        
        // middleware for parsing body requests
        router.all("/*", middleware: BodyParser())
        
        // get count of all menu items
        router.get("\(menuItemsPath)/count", handler: self.getMenuItemsCount)
        
        // get all menu items path
        router.get("\(menuItemsPath)", handler: self.getAllItems)
        
        // get specific menu item path
        router.get("\(menuItemsPath)/:id", handler: self.getMenuItem)
        
        // post a menu item path
        router.post("\(menuItemsPath)", handler: self.addMenuItem)
        
        // edit a menu item path
        router.put("\(menuItemsPath)/:id", handler: self.editMenuItem)
        
        // delete a menu item path
        router.delete("\(menuItemsPath)/:id", handler: self.deleteMenuItem)
        
        // find items by type path or subtype
        router.get("\(menuItemsPath)/categories/:type/:subtype?", handler: self.getMenuItemByType)

        // get all events
        router.get("\(eventItemsPath)", handler: self.getAllEventItems)
        
        // add an event
        router.post("\(eventItemsPath)", handler: self.addEvent)
        
        // get event 
        router.get("\(eventItemsPath)/:id", handler: self.getEvent)
        
        // update an event
        router.put("\(eventItemsPath)/:id", handler: self.updateEvent)
        
        // delete an event
        router.delete("\(eventItemsPath)/:id",handler: self.deleteEvent)
        
    }
    
    // MARK: - Menu Item Handlers
    // POST handler for adding a menu item
    private func addMenuItem(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        
        defer { next() }
        
        guard let body = request.body else {
            Log.error("Could not find body in request")
            response.status(.badRequest)
            return
        }
        
        guard case let .json(json) = body else {
            Log.error("Invalid JSON supplied")
            response.status(.badRequest)
            return
        }
        
        let itemType: String = json["itemtype"].stringValue
        let itemSubType: String = json["itemsubtype"].stringValue
        let itemName: String = json["itemname"].stringValue
        let itemPrice: Double = json["itemprice"].doubleValue
        let imgUrl: String = json["imgurl"].stringValue
        
        rest.addMenuItem(itemType: itemType, itemSubType: itemSubType, itemName: itemName, itemPrice: itemPrice, imgUrl: imgUrl) { (menuItem, error) in
            guard error == nil else {
                Log.error(error!.localizedDescription)
                try? response.status(.badRequest).end()
                return
            }
            
            if let menuItem = menuItem {
                try? response.status(.OK).send(json: JSON(menuItem.toDict())).end()
            }
        }
    }
    
    // GET handler for getting all items
    private func getAllItems(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        
        defer { next() }
        rest.getMenuItems { (items, error) in
            
            guard error == nil else {
                Log.error(error!.localizedDescription)
                response.status(.badRequest)
                return
            }
            
            do {
                if let items = items {
                    try response.status(.OK).send(json: JSON(items.toDict())).end()
                    Log.info("Displaying items")
                } else {
                    try response.status(.internalServerError).end()
                }
            } catch {
                Log.error("Communications error")
            }
        }
    }
    
    // Getting a specific item
    private func getMenuItem(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        
        guard let id = request.parameters["id"] else {
            Log.error("ID not specified in request")
            response.status(.badRequest)
            return
        }
        
        defer { next() }
        
        rest.getMenuItem(id: id) { (menuItem, error) in
            
            guard error == nil else {
                Log.error("Could not get menu item")
                try? response.status(.badRequest).end()
                return
            }
            
            if let menuItem = menuItem {
                try? response.status(.OK).send(json: JSON(menuItem.toDict())).end()
                Log.info("Found menu item")
            }
        }
    }
    
    // Editing a menu item
    private func editMenuItem(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        
        guard let id = request.parameters["id"] else {
            Log.error("ID not specified in request")
            response.status(.badRequest)
            return
        }
        
        guard let body = request.body else {
            Log.error("Body not found in request")
            response.status(.badRequest)
            return
        }
        
        guard case let .json(json) = body else {
            Log.error("Invalid JSON specified")
            response.status(.badRequest)
            return
        }
        
        let name: String? = json["itemname"].stringValue == "" ? nil : json["itemname"].stringValue
        let type: String? = json["itemtype"].stringValue == "" ? nil : json["itemtype"].stringValue
        let subType: String? = json["itemsubtype"].stringValue == "" ? nil : json["itemsubtype"].stringValue
        let price: Double? = json["itemprice"].doubleValue == 0 ? nil : json["itemprice"].doubleValue
        let imgUrl: String? = json["imgurl"].stringValue == "" ? nil : json["imgurl"].stringValue
        
        defer { next() }
        
        rest.editMenuItem(id: id, itemType: type, itemSubType: subType, itemName: name, itemPrice: price, imgUrl: imgUrl) { (item, error) in
            
            guard error == nil else {
                Log.error(error!.localizedDescription)
                response.status(.badRequest)
                return
            }
            
            do {
                if let item = item {
                    try response.status(.OK).send(json: JSON(item.toDict())).end()
                    Log.info("Updated item: \(id)")
                } else {
                    Log.error("Could not unwrap item")
                }
            } catch {
                Log.error("Communications error")
            }
            
        }
        
    }
    
    // Delete a menu item
    private func deleteMenuItem(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let id = request.parameters["id"] else {
            Log.error("ID not found in request")
            response.status(.badRequest)
            return
        }
        
        defer { next() }
        rest.deleteMenuItem(id: id) { (error) in
            
            
            if error == nil {
                Log.info("Successfully deleted item")
                try? response.status(.OK).send("Item deleted successfully").end()
            } else {
                Log.error("Could not delete item")
                try? response.status(.internalServerError).end()
            }
            
            
        }
    }
    
    // Get menu items by type
    private func getMenuItemByType(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let type = request.parameters["type"] else {
            Log.error("Could not find type in request")
            response.status(.badRequest)
            return
        }
        
        let subType = request.parameters["subtype"]
        
        defer { next() }
        rest.getItemsByType(type: type, subType: subType) { (retrievedItems, error) in
            
            guard error == nil else {
                Log.error("Could not find items with that type")
                try? response.status(.badRequest).end()
                return
            }
            
            if let items = retrievedItems {
                
                try? response.status(.OK).send(json: JSON(items.toDict())).end()
                Log.info("Display items by type")
                
            }
            
            try? response.status(.internalServerError).end()
            Log.error("Communications error")
            
        }
    }
    
    // get count of all menu items
    private func getMenuItemsCount(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        
        rest.countMenuItems { (count, error) in
            guard error == nil else {
                Log.error("Could not get count of menu items")
                response.status(.internalServerError)
                return
            }
            
            try? response.status(.OK).send(json: JSON(["count" : count])).end()
        }
    }
    
    // MARK: Event handlers
    // get all events handler
    private func getAllEventItems(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        
        defer { next() }
        
        rest.getEventItems { (eventItems, error) in
            guard error == nil else {
                Log.error("Could not get event items")
                response.status(.badRequest)
                return
            }
            
            guard let eventItems = eventItems else {
                Log.debug("Could not get event items")
                response.status(.badRequest)
                return
            }
            
            try? response.status(.OK).send(json: JSON(eventItems.toDict())).end()
            
        }
        
    }
    
    private func addEvent(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        
        defer { next() }
        
        guard let body = request.body else {
            Log.error("Cannot find body in request")
            response.status(.badRequest)
            return
        }
        
        guard case let .json(json) = body else {
            Log.error("Invalid JSON supplied")
            response.status(.badRequest)
            return
        }
        
        if let eventName = json["eventname"].string, let eventDate = json["eventdate"].string, let eventDescription = json["eventdescription"].string {
            
            rest.addEvent(eventName: eventName, eventDate: eventDate, eventDescription: eventDescription, completion: { (addedItem, error) in
                guard error == nil else {
                    Log.error("Could not add event")
                    try? response.status(.internalServerError).end()
                    return
                }
                
                guard let addedItem = addedItem else {
                    Log.error("Could not add event")
                    try? response.status(.internalServerError).end()
                    return
                }
                
                try? response.status(.OK).send(json: JSON(addedItem.toDict())).end()
            })
        }
    }
    
    private func getEvent(request: RouterRequest, response: RouterResponse, next: () -> Void) {
       
        defer { next() }
        
        guard let id = request.parameters["id"] else {
            Log.error("Missing id in request")
            try? response.status(.badRequest).end()
            return
        }
        
        rest.getEventItem(id: id) { (eventItem, error) in
            guard error == nil else {
                Log.error("Could not get item")
                try? response.status(.internalServerError).end()
                return
            }
            
            guard let eventItem = eventItem else {
                Log.error("Could not get item")
                response.status(.internalServerError)
                return
            }
            
            try? response.status(.OK).send(json: JSON(eventItem.toDict())).end()
            
        }
    }
    
    private func updateEvent(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        
        guard let id = request.parameters["id"] else {
            Log.warning("Could not find id in request")
            response.status(.badRequest)
            return
        }
        
        guard let body = request.body else {
            Log.warning("Could not find body in request")
            response.status(.badRequest)
            return
        }
        
        guard case let .json(json) = body else {
            Log.warning("Invalid JSON supplied")
            response.status(.badRequest)
            return
        }
        
        let eventName = json["eventname"].stringValue == "" ? nil : json["eventname"].stringValue
        let eventDate = json["eventdate"].stringValue == "" ? nil : json["eventdate"].stringValue
        let eventDesc = json["eventdescription"].stringValue == "" ? nil : json["eventdescription"].stringValue
        
        rest.editEvent(id: id, eventName: eventName, eventDate: eventDate, eventDescription: eventDesc) { (editedItem, error) in
            guard error == nil else {
                Log.error(error!.localizedDescription)
                try? response.status(.internalServerError).end()
                return
            }
            
            guard let editedItem = editedItem else {
                Log.error(error!.localizedDescription)
                try? response.status(.internalServerError).end()
                return
            }
            
            try? response.status(.OK).send(json: JSON(editedItem.toDict())).end()
        }
    }
    
    private func deleteEvent(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        
        guard let id = request.parameters["id"] else {
            Log.warning("Could not find id in request")
            response.status(.badRequest)
            return
        }
        
        rest.deleteEvent(id: id) { (error) in
            guard error == nil else {
                Log.error(error!.localizedDescription)
                try? response.status(.internalServerError).end()
                return
            }
            
            try? response.status(.OK).send("event deleted successfully").end()
        }
    }
}
