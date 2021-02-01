/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import StoreKit

class Item {
    let candy: Candy?
    private let id = UUID()
    var candyProducts = [SKProduct]()

    init(candy: Candy? = nil, candyProducts: [SKProduct]) {
        self.candy = candy
        self.candyProducts = candyProducts
    }
    
    func loadProducts() {
        IAPManager.shared.getProducts { (productResults) in
            DispatchQueue.main.async {
                switch productResults {
                    case .success(let fetchedProducts):
                        self.candyProducts = fetchedProducts
                    case .failure(let error): print(error.localizedDescription)
                }
            }
        }
    }
    
    func getProduct(with identifier: String?) -> SKProduct? {
        guard let id = identifier else { return nil }
        return candyProducts.filter({ $0.productIdentifier == id }).first
    }
    
    func buyCandies(using product: SKProduct?, completion: @escaping (_ success: Bool) -> Void) {
        guard let product = product else { return }
        IAPManager.shared.buy(product: product) { (iapResult) in
            switch iapResult {
                case .success(let success):
                    if success {
                       // self.candies.filter({ $0.productID == product.productIdentifier }).first?.markAsPurchased()
                    }
                    completion(true)
                case .failure(_): completion(false)
            }
        }
    }
    
    func resetPurchasedState() {
       // candies.forEach { $0.markAsPurchased(false) }
    }
  
}

extension Item: Equatable, Hashable {
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.candy == rhs.candy && lhs.id == rhs.id && lhs.candyProducts == rhs.candyProducts
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(candy)
        hasher.combine(id)
        hasher.combine(candyProducts)
    }
}

class Candy: Codable {
    var id: Int?
    let name: String
    let category: Category
    let shouldShowDiscount: Bool
    var amount: Double? = 0.0
    var productID: String?
    var isPurchased = false
    
    init(id: Int?, name: String, category: Category, shouldShowDiscount: Bool, amount: Double? = 0.0, productID: String?, isPurchased: Bool) {
        self.id = id
        self.name = name
        self.category = category
        self.shouldShowDiscount = shouldShowDiscount
        self.amount = amount
        self.productID = productID
        self.isPurchased = isPurchased
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(Category.self, forKey: .category)
        shouldShowDiscount = try container.decode(Bool.self, forKey: .shouldShowDiscount)
        amount = try container.decode(Double.self, forKey: .amount)
        productID = try container.decode(String.self, forKey: .productID)
        getPurchasedState()
    }
    
    fileprivate func getPurchasedState() {
        guard let id = id else { return }
        isPurchased = UserDefaults.standard.bool(forKey: "\(id)")
    }
   
  enum Category: Codable {
    case all
    case chocolate
    case hard
    case other
  }
  
}

extension Candy: Equatable, Hashable {
    static func == (lhs: Candy, rhs: Candy) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.category == rhs.category && lhs.isPurchased == rhs.isPurchased && lhs.shouldShowDiscount == rhs.shouldShowDiscount && lhs.amount == rhs.amount && lhs.productID == rhs.productID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(category)
        hasher.combine(isPurchased)
        hasher.combine(shouldShowDiscount)
        hasher.combine(amount)
        hasher.combine(productID)
    }
}

extension Candy.Category: CaseIterable { }

extension Candy.Category: RawRepresentable {
  typealias RawValue = String
  
  init?(rawValue: RawValue) {
    switch rawValue {
    case "All": self = .all
    case "Chocolate": self = .chocolate
    case "Hard": self = .hard
    case "Other": self = .other
    default: return nil
    }
  }
  
  var rawValue: RawValue {
    switch self {
    case .all: return "All"
    case .chocolate: return "Chocolate"
    case .hard: return "Hard"
    case .other: return "Other"
    }
  }
}

extension Candy {
  static func candies() -> [Candy] {
    guard
      let url = Bundle.main.url(forResource: "candiesInfo", withExtension: "json"),
      let data = try? Data(contentsOf: url)
      else {
        return []
    }
    
    do {
      let decoder = JSONDecoder()
      return try decoder.decode([Candy].self, from: data)
    } catch {
      return []
    }
  }
    
   /* static func loadCandies() {
        guard let url = Bundle.main.url(forResource: "candiesInfo", withExtension: "json"), let data = try? Data(contentsOf: url) else {
            return
        }
        
        let decoder = JSONDecoder()
        guard let loadedCandies = try? decoder.decode([CandyInfo].self, from: data) else { return }
        
        var defaultCandy:[CandyInfo] = [CandyInfo]()
        
        for var candy in loadedCandies {
            
            candy.candy?.amount = 0.0
            
            defaultCandy.append(candy)
        }
        
        candies = defaultCandy
    }*/
}
