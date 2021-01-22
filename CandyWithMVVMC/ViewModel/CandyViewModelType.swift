
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
    func fetchCandies()
    func fetchCandyLocation()
    //var candyListViewModelType: CandyListViewModelType { get  set }
    var candies: Observable<[Candy]> { get  set }
    var candyLocations: Observable<[CandyLocation]> { get  set }
    var errorMessage: Observable<String?> { get set }
    var error: Observable<Error?> { get set }
 
}

protocol CandyViewModelCoordinatorDelegate: class {
    func didSelectCandy(_ row: Int, candy: Candy, from controller: UIViewController)
}


protocol CandyViewModelViewDelegate: class {
    func updateScreen()
}
