//
//  CandyDetailViewModelType.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

protocol CandyDetailViewModelType {
    
    var viewDelegate: CandyDetailViewModelViewDelegate? { get set }
    
    // Data Source
    func selectCandy() -> Candy?

    // Events
    func start()
    
}

protocol CandyDetailViewModelViewDelegate: class {
    func updateScreen()
}
