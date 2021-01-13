//
//  CandyViewModel.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

class CandyViewModel:NSObject {
    weak var coordinatorDelegate: CandyViewModelCoordinatorDelegate?
    //weak var viewDelegate: CandyViewModelViewDelegate?

    // MARK: - Properties
    
    var candies: Observable<[Candy]> = Observable([])
    var candyLocations: Observable<[CandyLocation]> = Observable([])
    var errorMessage: Observable<String?> = Observable(nil)
    var error: Observable<Error?> = Observable(nil)
    
    fileprivate let service: CandyService
 
    var candyListViewModel: CandyListViewModelType!

    fileprivate var isSearching: Bool = false
    
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
    
    func setError(_ error: Error) {
        self.errorMessage = Observable(error.localizedDescription)
        self.error = Observable(error)
    }
}

extension CandyViewModel: CandyViewModelType {
   

}

