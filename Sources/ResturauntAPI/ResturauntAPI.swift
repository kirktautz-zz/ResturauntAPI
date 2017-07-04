import Foundation

typealias JSONDictionary = [String: Any]

protocol DictionaryConvertable {
    func toDict() -> JSONDictionary
}

protocol Item {
    var id: String { get }
    var name: String { get }
    var date: String { get }
}

public protocol ResturauntAPI {
    
    // MARK: Menu items
    // Get all menu items
    func getMenuItems(completion: @escaping ([MenuItem]?, Error?) -> Void)
    
    // Get specific menu item
    func getMenuItem(id: String, completion: @escaping (MenuItem?, Error?) -> Void)
    
    // Add new menu item
    func addMenuFoodItem(itemType: String, itemSubType: String, itemName: String, itemPrice: Double, imgUrl: String, completion: @escaping (MenuItem?, Error?) -> Void)
    
    // Edit menu item
    func editMenuFoodItem(id: String, itemType: String?, itemSubType: String?, itemName: String?, itemPrice: Double?, imgUrl: String?, completion: @escaping (MenuItem?, Error?) -> Void)
    
    // delete menu item
    func deleteMenuItem(id: String, completion: @escaping (Error?) -> Void)
    
    // clear all items
    func clearMenuItems(completion: (Error?) -> Void)
    
    // get items by type
    func getItemsByType(type: String, completion: @escaping ([MenuItem]?, Error?) -> Void)
    
}
