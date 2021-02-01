//
//  CandyDetailViewModelType.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

protocol CandyDetailViewModelType {

    // Data Source
    func selectItem() -> Item?

    // Events
    func setUpByButton(isBuy: Bool)
    
    func createAmoutView(Add to: UIView)
    
    func createView(Add to: UIView)
    
    func configureView()
    
    func didTapBuyButton()
}
