
//
//  CandyViewModelType.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

protocol CandyViewModelType {
   // var viewDelegate: CandyViewModelViewDelegate? { get set }
    var coordinatorDelegate: CandyViewModelCoordinatorDelegate? { get set }
    
    // Data Source
    
    //func getAllCandies() -> [Candy]
    
    func fetchCandies()
    
    var candies: Observable<[Candy]> { get  set }
    var filterCandies: Observable<[Candy]> { get  set }
    
    var errorMessage: Observable<String?> { get set }
    var error: Observable<Error?> { get set }
    
    //var isSearching: Observable<Bool> { get set }
    
    func candiesTitle(row: Int) -> String
    func candiesCategory(row: Int) -> String

    func numberOfItems(searchFooter: SearchFooter) -> Int
    
    func itemFor(row: Int) -> CandyDetailViewDataType
    
    // Events
    //func start()
    
    func searchFor(text: String,  category: Candy.Category)
    
    func didSelectRow(_ row: Int, from controller: UIViewController)
    
    func didSelectClose(from controller: UIViewController)
    
    func didCloseSearchFunction()
}

protocol CandyViewModelCoordinatorDelegate: class {
    func didSelectCandy(_ row: Int, candy: Candy, from controller: UIViewController)
}

protocol CandyViewModelViewDelegate: class {
    func updateScreen()
}
