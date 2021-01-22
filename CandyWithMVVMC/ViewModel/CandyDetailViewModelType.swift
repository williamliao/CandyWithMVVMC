//
//  CandyDetailViewModelType.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

protocol CandyDetailViewModelType {
    
    //var coordinatorDelegate: CandyDetailViewModelCoordinatorDelegate? { get set }
    
    var viewDelegate: CandyDetailViewModelViewDelegate? { get set }
    
    // Data Source
    func selectCandy() -> Candy?

    // Events
    func setUpByButton(isBuy: Bool)
    
    func createAmoutView(Add to: UIView)
    
    func createView(Add to: UIView)
    
    func configureView()
    
    func didTapBuyButton()
}

protocol CandyDetailViewModelViewDelegate: class {
    func updateScreen()
}
