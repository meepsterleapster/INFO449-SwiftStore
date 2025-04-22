//
//  main.swift
//  Store
//
//  Created by Ted Neward on 2/29/24.
//

import Foundation

protocol SKU {
    var name : String {get}
    func price() -> Int
    func changePrice(_ newPrice: Int)
}

class Item: SKU {
    var item: (itemName: String, price: Int)
    var originalPrice : Int
    init(name: String, priceEach: Int) {
        self.item = (itemName: name, price: priceEach)
        self.originalPrice = priceEach
    }
    
    var name: String {
        return item.itemName
    }
    
    func price() -> Int {
        return item.price
    }
    
    func changePrice(_ newPrice: Int){
        item.price = newPrice
    }
}

class ItemByWeight : SKU {
    func changePrice(_ newPrice: Int) {
        item.price = newPrice
    }
    
    var item: (itemName: String, pounds: Int, price: Int)

    init(itemName: String, pounds: Int, price : Int) {
        self.item = (itemName: itemName, pounds: pounds, price : price)
      }
    
    var name: String {
        return item.itemName
    }
    
    func pricePerPound() -> Int {
        return item.price
    }
    
    func pounds() -> Int {
        return item.pounds
    }
    
    func price() -> Int {
        return Int(item.pounds * item.price)
    }
    
}

// I wanted to have a more fleshed out weight system, but cant develop it right now
//
//class ItemWeightDict {
//
//    var weightDict: [String: Int]
//
//    init() {
//        self.weightDict = [:]
//    }
//}

class Receipt {
    var receipt : [SKU];
    
    init(receipt: [SKU]) {
        self.receipt = receipt
    }
    
    func items() -> [SKU] {
        return receipt
    }
    
    func output() -> String {
        var printOut = "Receipt:\n"
        for item in receipt {
            printOut += "\(item.name): \(convertPriceToString(price: item.price()))\n"
        }
        printOut += "------------------\n"
        printOut += "TOTAL: \(convertPriceToString(price: total()))"
        print(printOut)
        return printOut
    }

    func convertPriceToString(price: Int) -> String {
        let price = Double(price) / 100
        return "$" + String(format: "%.2f", price)
    }

    
    func total() -> Int {
        var total = 0
        for item in receipt {
            total += item.price()
        }
        return total
    }

    
}

class Coupon {
    var percentageOff : Double
    var beenUsed : Bool
    var itemName : String
    
    init(itemName : String, percentageOff: Double) {
        self.percentageOff = percentageOff
        self.itemName = itemName
        self.beenUsed = false
    }
    
    func applyCoupon (receipt: [SKU]) {
        guard !beenUsed else { return }
        for item in receipt{
            if item.name == itemName{
                item.changePrice(Int(percentageOff * Double(item.price())))
                beenUsed = true
                break
            }
        }
    }
}
class RainCheck {
    var itemName : String
    var newPrice : Int
    var beenRedeemed : Bool
    var quantity : Int?
    var offerWeight : Int?

    convenience init(itemName: String, _ newPrice: Int) {
        self.init(itemName: itemName, newPrice, quantity: 1, offerWeight: nil)
        self.quantity = nil
    }

    init(itemName: String, _ newPrice: Int, quantity: Int?) {
        self.itemName = itemName
        self.newPrice = newPrice
        self.quantity = quantity
        self.offerWeight = nil
        self.beenRedeemed = false
    }

    init(itemName: String, _ newPrice: Int, offerWeight: Int?) {
        self.itemName = itemName
        self.newPrice = newPrice
        self.quantity = nil
        self.offerWeight = offerWeight
        self.beenRedeemed = false
    }

    private init(itemName: String, _ newPrice: Int, quantity: Int?, offerWeight: Int?) {
        self.itemName = itemName
        self.newPrice = newPrice
        self.quantity = quantity
        self.offerWeight = offerWeight
        self.beenRedeemed = false
    }

    func applyRaincheck(Receipt : Receipt) {
        var appliedSomething = false
        
        if var currentQty = quantity {
            let initialQty = currentQty
            guard currentQty > 0 else { return }
            
            for item in Receipt.receipt {
                guard currentQty > 0 else { break }
                
                if item.name == itemName && !(item is ItemByWeight) {
                    if item.price() > newPrice {
                        item.changePrice(newPrice)
                        currentQty -= 1
                        appliedSomething = true
                    }
                }
            }
            self.quantity = currentQty
            if currentQty == 0 && initialQty > 0 {
                self.beenRedeemed = true
            } else if appliedSomething && initialQty == 1 {
                self.beenRedeemed = true
            }
            
        } else if var currentWeight = offerWeight {
            let initialWeight = currentWeight
            guard currentWeight > 0 else { return }
            
            for item in Receipt.receipt {
                guard currentWeight > 0 else { break }
                
                if let weightedItem = item as? ItemByWeight,
                   weightedItem.name == itemName
                {
                    let itemWeight             = weightedItem.item.pounds
                    let originalPricePerPound  = weightedItem.pricePerPound()
                    
                    guard originalPricePerPound > newPrice else { continue }
                    
                    if currentWeight >= itemWeight {
                        weightedItem.changePrice(newPrice)
                        currentWeight -= itemWeight
                        appliedSomething = true
                    } else {
                        let discountedCost = currentWeight * newPrice
                        let remaining      = itemWeight - currentWeight
                        let normalCost     = remaining * originalPricePerPound
                        let totalCost      = discountedCost + normalCost
                        
                        let avgPerPound = totalCost / itemWeight
                        weightedItem.changePrice(avgPerPound)
                        
                        currentWeight = 0
                        appliedSomething = true
                    }
                    
                    break
                }
            }
            
            self.offerWeight = currentWeight
            if currentWeight == 0 && initialWeight > 0 {
                self.beenRedeemed = true
            }
        }else {
            guard !beenRedeemed else { return }

            for item in Receipt.receipt {
                if item.name == itemName && !(item is ItemByWeight) {
                    print(item.price())
                    if item.price() > newPrice {
                        item.changePrice(newPrice)
                        print(item.price())
                        self.beenRedeemed = true
                        break
                    }
                }
            }
        }
    }
}


class PricingScheme {
    
    // How do we modify a receipt?
    // init a pricing scheme?
    // I am going insane
    enum Value {
        
        case string(String)
        case grouped(String,String)
    }
    
    var offers : [Value]
    
    var curReceipt : Receipt?
    
    init() {
        self.offers = []
    }
    
    // for buy two get one
    func updateRecepit(Receipt : Receipt){
        curReceipt = Receipt
    }
    
    // for grouped purchases
    func addGroupedOffer(_ item1: String, _ item2: String) {
        offers.append(.grouped(item1, item2))
    }
    
    
    func addOffer(itemName : String){
        offers.append(.string(itemName))
    }
    
    func calcOffers() {
        guard let receipt = curReceipt else { return }
        
        for offer in offers {
            switch offer {
            case .string(let name):
                var count = 0
                for item in receipt.items() {
                    if item.name == name {
                        count += 1
                        if count % 3 == 0 {
                            item.changePrice(0)
                        }
                    }
                }
                
            case .grouped(let item1, let item2):
                var queue1 = [Int]()
                var queue2 = [Int]()
                
                for (index, item) in receipt.items().enumerated() {
                    if item.name.contains(item1) {
                        queue1.append(index)
                    } else if item.name.contains(item2) {
                        queue2.append(index)
                    }
                }
                
                while !queue1.isEmpty && !queue2.isEmpty {
                    let index1 = queue1.removeFirst()
                    let index2 = queue2.removeFirst()
                    
                    if let itemA = receipt.items()[index1] as? Item,
                       let itemB = receipt.items()[index2] as? Item {
                        let discountedA = Int(Double(itemA.originalPrice) * 0.9)
                        let discountedB = Int(Double(itemB.originalPrice) * 0.9)
                        itemA.changePrice(discountedA)
                        itemB.changePrice(discountedB)
                    }
                }
            }
        }
        
    }
    
}

class Register {
    
    var newReceipt = Receipt(receipt: [])
    var pricingScheme = PricingScheme()
    
    func scan(_ item: SKU) {
        if item is ItemByWeight{
            
        }
        newReceipt.receipt.append(item)
    }
    
    func subtotal() -> Int {
        pricingScheme.updateRecepit(Receipt: newReceipt)
        pricingScheme.calcOffers()
        var subTotal = 0
        for item in newReceipt.receipt {
            print(item.name)
            subTotal += item.price()
        }
        return subTotal
    }


    
    func total() -> Receipt {
        pricingScheme.updateRecepit(Receipt: newReceipt)
        pricingScheme.calcOffers()
        let total = newReceipt
        newReceipt = Receipt(receipt: [])
        return total
    }

    
    
}

class Store {
    let version = "0.1"
    func helloWorld() -> String {
        return "Hello world"
    }
}

