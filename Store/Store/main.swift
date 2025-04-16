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
    
}

class Item: SKU {
    var item: (itemName: String, price: Int)
    
    init(name: String, priceEach: Int) {
        self.item = (itemName: name, price: priceEach)
    }
    
    var name: String {
        return item.itemName
    }
    
    func price() -> Int {
        return item.price
    }
}

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

class Register {
    
    var newReceipt = Receipt(receipt: [])

    
    func scan(_ item: SKU) {
        newReceipt.receipt.append(item)
    }
    
    func subtotal() -> Int {
        var subTotal = 0
        for item in newReceipt.receipt {
            subTotal += item.price()
        }
        return subTotal
    }


    
    func total() -> Receipt {
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

