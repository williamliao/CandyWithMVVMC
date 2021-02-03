//
//  CandyViewModel.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit
import Combine
import StoreKit

class CandyViewModel:NSObject {
    // MARK: - Properties
    private var cancellable: AnyCancellable?
    
    var verifyReceipt:Observable<VerifyReceiptResponse?> = Observable(nil)
    var recipeProducts:Observable<[SKProduct]> = Observable([])
    
    var recipeSubscriptionsProducts:Observable<[SKProduct]> = Observable([])
    
    var candies: Observable<[Candy]> = Observable([])
    var buyCandies: Observable<Set<Candy>> = Observable(Set<Candy>())

    var candyLocations: Observable<[CandyLocation]> = Observable([])
    var errorMessage: Observable<String?> = Observable(nil)
    var error: Observable<Error?> = Observable(nil)
    
    var filterCandies: Observable<[Candy]> = Observable([])
    var filterBuyCandies: Observable<Set<Candy>> = Observable(Set<Candy>())
    
    fileprivate let service: CandyService
 
    var candyListViewModel: CandyListViewModelType!

    var isSearching: Observable<Bool> = Observable(false)
    
//    var isFiltering: Bool {
//      return searchController.isActive && !isSearchBarEmpty
//    }
    
    init(service: CandyService) {
        self.service = service
        super.init()
    }
    
    func fetchCandies() {
        self.service.getCandy(withText: "Test") { [weak self] (result) in
            switch result {
            case .value(let candyViewData):
                let candyViewDataType: CandyViewDataType = candyViewData
                
                self?.candies.value = candyViewDataType.candies
               // self?.viewDelegate?.updateScreen()
            case .error(let error):
                self?.setError(error)
                break
            }
        }
    }
    
    func fetchCandyLocation() {
        self.service.getCandyLocation(withText: "Test") { [weak self] (result) in
            switch result {
            case .value(let candyViewData):
                let candyLocationViewDataType: CandyLocationViewData = candyViewData
                
                self?.candyLocations.value = candyLocationViewDataType.candyLocations
               // self?.viewDelegate?.updateScreen()
            case .error(let error):
                self?.setError(error)
                break
            }
        }
    }
    
    func fetchVerifyReceipt() {
        self.service.getVerifyReceipt { [weak self] (result) in
            switch result {
            case .value(let verifyReceipt):
                self?.verifyReceipt.value = verifyReceipt
            case .error(let error):
                self?.setError(error)
                break
            }
        }
    }
    
    func getProducts() {
        IAPManager.shared.getProducts { (productResults) in
            DispatchQueue.main.async {
                switch productResults {
                    case .success(let fetchedProducts):
                        self.recipeProducts.value = fetchedProducts
                    case .failure(let error): print(error.localizedDescription)
                }
            }
        }
    }
    
    func getSubscriptions() {
        IAPManager.shared.getAutoSubscriptionProducts { (productResults) in
            DispatchQueue.main.async {
                switch productResults {
                    case .success(let fetchedProducts):
                        self.recipeSubscriptionsProducts.value = fetchedProducts
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
        }
    }
    
    func getProduct(with identifier: String?) -> SKProduct? {
        guard let id = identifier else { return nil }
        return recipeProducts.value.filter({ $0.productIdentifier == id }).first
    }
    
    func getSubscription(with identifier: String?) -> SKProduct? {
        guard let id = identifier else { return nil }
        return recipeSubscriptionsProducts.value.filter({ $0.productIdentifier == id }).first
    }
    
    func resetPurchasedState() {
        candies.value.forEach { markAsPurchased(false, candy: $0, amount: 0) }
    }
    
    func getPurchasedState(candy: inout Candy) {
        guard let id = candy.id else { return }
        candy.isPurchased = UserDefaults.standard.bool(forKey: "\(id)")
    }
    
    func markAsPurchased(_ state: Bool = true, candy: Candy, amount: Double) {
        guard let id = candy.productID else { return }
        candy.isPurchased = state
        candy.amount = amount
        DispatchQueue.main.async {
            do {
                let userDefaults = UserDefaults.standard
                try userDefaults.setObject(candy, forKey: "\(id)")
            } catch  {
                print(error)
            }
        }
    }
    
    func clearProducts() {
        buyCandies.value.removeAll()
    }
    
    func setError(_ error: Error) {
        self.errorMessage = Observable(error.localizedDescription)
        self.error = Observable(error)
    }
}

extension CandyViewModel: CandyViewModelType {
  
   

}

