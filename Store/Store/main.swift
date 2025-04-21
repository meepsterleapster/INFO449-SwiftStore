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

class PricingScheme {
    
    // How do we modify a receipt?
    // init a pricing scheme?
    
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

