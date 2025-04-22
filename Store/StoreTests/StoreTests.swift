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
    
    func testCoupon() {
            
            let register = Register()
            let coupon = Coupon(itemName: "Milk (1L)", percentageOff: 0.8)
            
            
            register.scan(Item(name: "Beans (8oz Can)", priceEach: 200))
            register.scan(Item(name: "Milk (1L)", priceEach: 500))
            
            
            coupon.applyCoupon(receipt: register.newReceipt.items())
            
            
            let subtotal = register.subtotal()
            let receipt = register.total()
            let total = receipt.total()
            
            
            XCTAssertEqual(subtotal, 200 + 400)
            XCTAssertEqual(total, 200 + 400)
            XCTAssertEqual(coupon.beenUsed, true)
        }
        
        func testCouponOnlyAppliesOnceEvenIfAppliedAgainBeforeTotal() {
            let register = Register()
            let coupon = Coupon(itemName: "Milk", percentageOff: 0.5) // 50% off
            
            register.scan(Item(name: "Milk", priceEach: 400))
            register.scan(Item(name: "Milk", priceEach: 400))
            
            
            coupon.applyCoupon(receipt: register.newReceipt.items())
            coupon.applyCoupon(receipt: register.newReceipt.items())
            
            let subtotal = register.subtotal()
            let receipt = register.total()
            
            XCTAssertEqual(subtotal, 600)
            XCTAssertEqual(receipt.total(), 600)
            
        }
    
    // Challenge myself, see if I can combine a buy two get one and a coupon in a single one
    
    func testBTGOAndCoupon() {
        let register = Register()
        register.pricingScheme.addOffer(itemName: "Gum")

        let gum1 = Item(name: "Gum", priceEach: 100)
        let gum2 = Item(name: "Gum", priceEach: 100)
        let gum3 = Item(name: "Gum", priceEach: 100)

        register.scan(gum1)
        register.scan(gum2)
        register.scan(gum3)

        let coupon = Coupon(itemName: "Gum", percentageOff: 0.5)
        coupon.applyCoupon(receipt: register.newReceipt.items())

        let receipt = register.total()
        // so half off first, and the third should be free, yeah in real-life you probably cant combine
        // offers, but whatever
        let expectedTotal = 50 + 100 + 0

        XCTAssertEqual(expectedTotal, receipt.total())
    }

    func testRainCheckQuantity() {
        let register = Register()
        register.scan(Item(name: "Milk (1L)", priceEach: 500))
        register.scan(Item(name: "Milk (1L)", priceEach: 500))
        register.scan(Item(name: "Milk (1L)", priceEach: 500))

        
        
        let receipt = register.newReceipt
        let rainCheck = RainCheck(itemName: "Milk (1L)", 400, quantity: 2)
        rainCheck.applyRaincheck(Receipt: receipt)

        XCTAssertEqual(1300, receipt.total())
        XCTAssertTrue(rainCheck.beenRedeemed)
        XCTAssertEqual(rainCheck.quantity, 0)

        let rainCheck2 = RainCheck(itemName: "Milk (1L)", 350, quantity: 1)
        rainCheck2.applyRaincheck(Receipt: receipt)

        XCTAssertEqual(1250, receipt.total())
        XCTAssertTrue(rainCheck2.beenRedeemed)
        XCTAssertEqual(rainCheck2.quantity, 0)
    }
    func testRainCheckWeight() {
        let register = Register()
        let apples = ItemByWeight(itemName: "Apples", pounds: 5, price: 150)
        register.scan(apples)

        let receipt = register.newReceipt
        let rainCheck = RainCheck(itemName: "Apples", 100, offerWeight: 3)
        rainCheck.applyRaincheck(Receipt: receipt)

        XCTAssertEqual(600, receipt.total())
        XCTAssertTrue(rainCheck.beenRedeemed)
        XCTAssertEqual(rainCheck.offerWeight, 0)

        let register2 = Register()
        let bananas = ItemByWeight(itemName: "Bananas", pounds: 2, price: 200)
        register2.scan(bananas)

        let receipt2 = register2.newReceipt
        let rainCheck2 = RainCheck(itemName: "Bananas", 150, offerWeight: 3)
        rainCheck2.applyRaincheck(Receipt: receipt2)

        XCTAssertEqual(300, receipt2.total())
        XCTAssertFalse(rainCheck2.beenRedeemed)
        XCTAssertEqual(rainCheck2.offerWeight, 1)
    }

    func testRainCheckSingleItem() {
        let register = Register()
        let bread = Item(name: "Bread", priceEach: 300)
        register.scan(bread)

        let receipt = register.newReceipt
        let rainCheck = RainCheck(itemName: "Bread", 250)
        rainCheck.applyRaincheck(Receipt: receipt)

        XCTAssertEqual(250, receipt.total())
        XCTAssertTrue(rainCheck.beenRedeemed)

        let rainCheck2 = RainCheck(itemName: "Bread", 200)
        rainCheck2.applyRaincheck(Receipt: receipt)

        XCTAssertEqual(200, receipt.total())
        XCTAssertTrue(rainCheck2.beenRedeemed)
    }

    func testRainCheckNotApplicableItem() {
        let register = Register()
        let soda = Item(name: "Soda", priceEach: 150)
        register.scan(soda)

        let rainCheck = RainCheck(itemName: "Juice", 100)
        rainCheck.applyRaincheck(Receipt: register.newReceipt)

        let receipt = register.total()
        XCTAssertEqual(150, receipt.total()) // No change
        XCTAssertFalse(rainCheck.beenRedeemed) // Not applied, not redeemed
    }

        
    }

