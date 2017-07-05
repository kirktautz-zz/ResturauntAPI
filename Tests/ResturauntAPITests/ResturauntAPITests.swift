import XCTest
@testable import ResturauntAPI

class ResturauntAPITests: XCTestCase {
    
    static var allTests = [
        ("testGetAllMenuItems", testGetAllMenuItems), ("testAddAndGetItem", testAddAndGetItem), ("testEditItem", testEditItem), ("testDeleteItem", testDeleteItem), ("testMenuItemCount", testMenuItemCount)
    ]
    
    var rest: Resturaunt?
    
    override func setUp() {
        rest = Resturaunt()
        super.setUp()
    }
    
    override func tearDown() {
        guard let rest = rest else {
            XCTFail()
            return
        }
        
        rest.clearMenuItems { (error) in
            guard error == nil else {
                XCTFail()
                return
            }
        }
        super.tearDown()
    }
    
    // Test adding a menu item
    func testAddAndGetItem() {
        guard let rest = rest else {
            XCTFail()
            return
        }
        
        let addMenuItemExp = expectation(description: "Add a menu item")
        
        rest.addMenuFoodItem(itemType: "TEST", itemSubType: "TEST", itemName: "TEST", itemPrice: 0, imgUrl: "TEST") { (item, error) in
            guard error == nil else {
                XCTFail()
                return
            }
            
            guard let item = item else {
                XCTFail()
                return
            }
            
            rest.getMenuItem(id: item.id, completion: { (retItem, error) in
                guard error == nil else {
                    XCTFail()
                    return
                }
                
                if let retItem = retItem {
                    XCTAssertEqual(item.id, retItem.id)
                    addMenuItemExp.fulfill()
                }
            })
        }
        
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error)
        }
    }
    
    // Test getting all menu items
    func testGetAllMenuItems() {
        guard let rest = rest else {
            XCTFail()
            return
        }
        
        let getAllExpec = expectation(description: "Get all menu items")
        
        
        rest.addMenuFoodItem(itemType: "TEST", itemSubType: "TEST", itemName: "TEST", itemPrice: 0, imgUrl: "TEST") { (addedItem, error) in
            
            guard let addedItemId = addedItem?.id else {
                XCTFail()
                return
            }
            
            rest.getMenuItems { (items, error) in
                guard error == nil else {
                    XCTFail()
                    return
                }
                
                guard let items = items else {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(items.first?.id, addedItemId)
                getAllExpec.fulfill()
                
            }
        }
        
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testEditItem() {
        guard let rest = rest else {
            XCTFail()
            return
        }
        
        let editMenuItemExp = expectation(description: "Edit a menu item")
        
        rest.addMenuFoodItem(itemType: "TEST", itemSubType: "TEST", itemName: "TEST", itemPrice: 0, imgUrl: "TEST") { (addedItem, error) in
            guard error == nil else {
                XCTFail()
                return
            }
            
            guard let addedItem = addedItem else {
                XCTFail()
                return
            }
            
            rest.editMenuFoodItem(id: addedItem.id, itemType: nil, itemSubType: nil, itemName: "UpdatedTest", itemPrice: nil, imgUrl: nil, completion: { (updatedItem, error) in
                guard error == nil else {
                    XCTFail()
                    return
                }
                
                rest.getMenuItem(id: addedItem.id, completion: { (item, error) in
                    guard error == nil else {
                        XCTFail()
                        return
                    }
                    
                    if let item = item {
                        XCTAssertEqual(item.name, "UpdatedTest")
                        editMenuItemExp.fulfill()
                    }
                })
            })
        }
        
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testDeleteItem() {
        guard let rest = rest else {
            XCTFail()
            return
        }
        
        let deleteItemExp = expectation(description: "Delete an item")
        
        rest.addMenuFoodItem(itemType: "TEST", itemSubType: "TEST", itemName: "TEST", itemPrice: 0, imgUrl: "TEST") { (addedItem, error) in
            guard error == nil else {
                XCTFail()
                return
            }
            
            guard let addedItem = addedItem else {
                XCTFail()
                return
            }
            
            rest.deleteMenuItem(id: addedItem.id, completion: { (error) in
                guard error == nil else {
                    XCTFail()
                    return
                }
                
                XCTAssertNil(error)
                deleteItemExp.fulfill()
            })
        }
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error)
        }
    }
    
    // test menu items count - added 5 items
    func testMenuItemCount() {
        
        guard let rest = rest else {
            XCTFail()
            return
        }
        
        let countMenuItemsExp = expectation(description: "Count menu items")
        
        for _ in 1...5 {
            rest.addMenuFoodItem(itemType: "test", itemSubType: "test", itemName: "test", itemPrice: 0, imgUrl: "test", completion: { (item, error) in
                guard error == nil else {
                    XCTFail()
                    return
                }
            })
        }
        
        rest.countMenuItems { (count, error) in
            guard error == nil else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(count, 5)
            countMenuItemsExp.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error)
        }
    }
}
