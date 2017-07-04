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
    
    public init(backend: ResturauntAPI) {
        self.rest = backend
        routerSetup()
    }
    
    // MARK: - Routes
    public func routerSetup() {
        
        router.all("/*", middleware: BodyParser())
        router.get("\(menuItemsPath))", handler: self.getAllItems)
        router.post("\(menuItemsPath)", handler: self.addMenuItem)
    }
    
    private func addMenuItem(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        
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
        let date: String = json["date"].stringValue
        
        rest.addMenuFoodItem(itemType: itemType, itemSubType: itemSubType, itemName: itemName, itemPrice: itemPrice, imgUrl: imgUrl, date: date) { (menuItem, error) in
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
    
    private func getAllItems(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        
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
    
}
