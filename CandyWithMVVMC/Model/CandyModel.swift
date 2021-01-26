//
//  CandyModel.swift
//  CandyWithMVVMC
//
//  Created by william on 2021/1/26.
//  Copyright © 2021 william. All rights reserved.
//

import Foundation
import StoreKit

@available(iOS 13.0, *)
class CandyModel: ObservableObject {
    @Published var candies = [CandyInfo]()
    @Published var candyProducts = [SKProduct]()
    
    init() {
        loadCandies()
        loadProducts()
    }
    
    private func loadCandies() {
        guard let url = Bundle.main.url(forResource: "candiesInfo", withExtension: "json"), let data = try? Data(contentsOf: url) else {
            return
        }
        
        let decoder = JSONDecoder()
        guard let loadedCandies = try? decoder.decode([CandyInfo].self, from: data) else { return }
        candies = loadedCandies
    }
    
    fileprivate func loadProducts() {
        IAPManager.shared.getProducts { (productResults) in
            DispatchQueue.main.async {
                switch productResults {
                    case .success(let fetchedProducts): self.candyProducts = fetchedProducts
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
                        self.candies.filter({ $0.productID == product.productIdentifier }).first?.markAsPurchased()
                    }
                    completion(true)
                case .failure(_): completion(false)
            }
        }
    }
    
    func resetPurchasedState() {
        candies.forEach { $0.markAsPurchased(false) }
    }
}
