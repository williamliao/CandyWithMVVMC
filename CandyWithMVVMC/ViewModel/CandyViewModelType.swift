
//
//  CandyViewModelType.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

protocol CandyViewModelType {

    var isSearching: Observable<Bool> { get set }

    // Data Source
    func fetchCandies()
    func fetchCandyLocation()
    //var candyListViewModelType: CandyListViewModelType { get  set }
    var candies: Observable<[Candy]> { get  set }
    var buyCandies: Observable<Set<Candy>> { get  set }
    var candyLocations: Observable<[CandyLocation]> { get  set }
    var errorMessage: Observable<String?> { get set }
    var error: Observable<Error?> { get set }
    
    var filterCandies: Observable<[Candy]> { get  set }
    var filterBuyCandies: Observable<Set<Candy>> { get  set }
 
}
