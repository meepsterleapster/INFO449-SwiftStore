//
//  StoreTests.swift
//  StoreTests
//
//  Created by Ted Neward on 2/29/24.
//

import XCTest

final class StoreTests: XCTestCase {

    var register = Register()

    override func setUpWithError() throws {
        register = Register()
    }

    override func tearDownWithError() throws { }

    func testBaseline() throws {
        XCTAssertEqual("0.1", Store().version)
        XCTAssertEqual("Hello world", Store().helloWorld())
    }
    
    func testOneItem() {
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        XCTAssertEqual(199, register.subtotal())
        
        let receipt = register.total()
        XCTAssertEqual(199, receipt.total())

        let expectedReceipt = """
Receipt:
Beans (8oz Can): $1.99
------------------
TOTAL: $1.99
"""
        XCTAssertEqual(expectedReceipt, receipt.output())
    }
    
    func testThreeSameItems() {
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        XCTAssertEqual(199 * 3, register.subtotal())
    }
    
    func testThreeDifferentItems() {
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        XCTAssertEqual(199, register.subtotal())
        register.scan(Item(name: "Pencil", priceEach: 99))
        XCTAssertEqual(298, register.subtotal())
        register.scan(Item(name: "Granols Bars (Box, 8ct)", priceEach: 499))
        XCTAssertEqual(797, register.subtotal())
        
        let receipt = register.total()
        XCTAssertEqual(797, receipt.total())

        let expectedReceipt = """
Receipt:
Beans (8oz Can): $1.99
Pencil: $0.99
Granols Bars (Box, 8ct): $4.99
------------------
TOTAL: $7.97
"""
        XCTAssertEqual(expectedReceipt, receipt.output())
    }
    
    func testBuyTwoGetOne() {
        // test exactly 3 items
        register.pricingScheme.addOffer(itemName: "Beans (8oz Can)")
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        XCTAssertEqual(199 * 2, register.subtotal())
        var receipt = register.total()
        XCTAssertEqual(199*2, receipt.total())
        
        // if we add a fourth item, should be the cost of 3 items
        register.pricingScheme.addOffer(itemName: "Beans (8oz Can)")
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Pencil", priceEach: 99))
        receipt = register.total()
        XCTAssertEqual(696, receipt.total())
        
        // test if this pricing scheme affects other items
        register.pricingScheme.addOffer(itemName: "Beans (8oz Can)")
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        receipt = register.total()
        XCTAssertEqual(597, receipt.total())
    }
    
    func testGroupedPurchase() {
        // as specfied by the Spec, make sure its brand agnostic
        register.pricingScheme.addGroupedOffer("Ketchup", "Beer")
        
        
        register.scan(Item(name: "Classic Ketchup", priceEach: 500))
        register.scan(Item(name: "Lager Beer", priceEach: 300))
        register.scan(Item(name: "Spicy Ketchup", priceEach: 400))
        register.scan(Item(name: "IPA Beer", priceEach: 200))

        let total = register.total()
        
 
        let expectedTotal = 450 + 270 + 360 + 180
        
        XCTAssertEqual(expectedTotal, total.total())
    }
    
    func testMixedWeightedAndRegularItems() {
        let bananas = ItemByWeight(itemName: "Bananas", pounds: 3, price: 100) 
        let cereal = Item(name: "Corn Flakes", priceEach: 450)

        register.scan(bananas)
        register.scan(cereal)

        let total = register.total()
        
        let expectedTotal = 3 * 100 + 450

        XCTAssertEqual(expectedTotal, total.total())
    }


}
