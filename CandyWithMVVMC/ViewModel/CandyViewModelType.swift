
//
//  CandyViewModelType.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

protocol CandyViewModelType {
    var viewDelegate: CandyViewModelViewDelegate? { get set }
    var coordinatorDelegate: CandyViewModelCoordinatorDelegate? { get set }
    
    // Data Source
    
    func getAllCandies() -> [Candy]

    func numberOfItems() -> Int
    
    func itemFor(row: Int) -> CandyDetailViewDataType
    
    // Events
    //func start()
    
    func searchFor(text: String)
    
    func didSelectRow(_ row: Int, from controller: UIViewController)
    
    func didSelectClose(from controller: UIViewController)
}

protocol CandyViewModelCoordinatorDelegate: class {
    func didSelectCandy(_ row: Int, candy: Candy, from controller: UIViewController)
}

protocol CandyViewModelViewDelegate: class {
    func updateScreen()
}
