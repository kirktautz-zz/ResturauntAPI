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
    
    // Add new menu item
    func addMenuFoodItem(itemType: String, itemSubType: String, itemName: String, itemPrice: Double, imgUrl: String, date: String, completion: @escaping (MenuItem?, Error?) -> Void)
    
}
