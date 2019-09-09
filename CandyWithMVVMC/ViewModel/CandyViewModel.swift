//
//  CandyViewModel.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

class CandyViewModel: NSObject {
    weak var coordinatorDelegate: CandyViewModelCoordinatorDelegate?
    weak var viewDelegate: CandyViewModelViewDelegate?

    // MARK: - Properties
    
    fileprivate let service: CandyService
    
    fileprivate var candies: [Candy] = []
    
    fileprivate var filterCandies: [Candy] = []
    
    fileprivate var isSearching = false
    
    init(service: CandyService) {
        self.service = service
        super.init()
        service.getCandy(withText: "Test") { [weak self] (result) in
            switch result {
            case .value(let candyViewData):
                let candyViewDataType: CandyViewDataType = candyViewData
                self?.candies = candyViewDataType.candies
                self?.viewDelegate?.updateScreen()
            case .error(let error):
                print(error)
                break
            }
        }
        
    }
}

extension CandyViewModel: CandyViewModelType {
    
    func getAllCandies() -> [Candy] {
        return self.candies
    }
    
    func numberOfItems() -> Int {
        return isSearching ? filterCandies.count : candies.count
    }
    
    func itemFor(row: Int) -> CandyDetailViewDataType  {
        let candy = isSearching ? filterCandies[row] : candies[row]
        let dataType: CandyDetailViewDataType = CandyDetailViewData(candy: candy)
        return dataType
    }
    
    func searchFor(text: String) {
        guard !text.isEmpty else {
            isSearching = false
            return
        }
        
        isSearching = true
        filterCandies = []
        viewDelegate?.updateScreen()
    }
    
    func didSelectRow(_ row: Int, from controller: UIViewController) {
        let candy = isSearching ? filterCandies[row] : candies[row]
        coordinatorDelegate?.didSelectCandy(row, candy: candy, from: controller)
    }
    
    func didSelectClose(from controller: UIViewController) {
        
    }
}


