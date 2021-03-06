//
//  CandyInfo.swift
//  CandyWithMVVMC
//
//  Created by william on 2021/1/26.
//  Copyright © 2021 william. All rights reserved.
//

import Foundation
import Combine

@available(iOS 13.0, *)
class CandyInfo: Codable, Identifiable, ObservableObject {
    var id: Int?
    var candy: Candy?
    var buyCandies: Candy?
    var productID: String?
    @Published var isPurchased = false
   
    init(id: Int?, candy: Candy?, productID: String? = "") {
        self.id = id
        self.candy = candy
        self.productID = productID
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        candy = try container.decode(Candy.self, forKey: .candy)
        productID = try container.decode(String.self, forKey: .productID)
        getPurchasedState()
    }
    
    fileprivate func getPurchasedState() {
        guard let id = id else { return }
        isPurchased = UserDefaults.standard.bool(forKey: "\(id)")
    }
    
    
    func markAsPurchased(_ state: Bool = true) {
        guard let id = id else { return }
        isPurchased = state
        UserDefaults.standard.set(state, forKey: "\(id)")
    }
    
    enum CodingKeys: CodingKey {
        case id, candy, productID
    }
}

extension CandyInfo: Equatable, Hashable {
    static func == (lhs: CandyInfo, rhs: CandyInfo) -> Bool {
        return lhs.id == rhs.id && lhs.candy == rhs.candy && lhs.productID == rhs.productID && lhs.isPurchased == rhs.isPurchased
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(candy)
        hasher.combine(productID)
        hasher.combine(isPurchased)
    }
}
