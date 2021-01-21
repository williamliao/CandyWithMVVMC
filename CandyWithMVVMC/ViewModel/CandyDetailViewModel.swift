//
//  CandyDetailViewModel.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

class CandyDetailViewModel {
    
    weak var viewDelegate: CandyDetailViewModelViewDelegate?
    
    var candy: Candy?
    
    var candyDataType: CandyDetailViewDataType?
    
    func start() {
        viewDelegate?.updateScreen()
    }
}

extension CandyDetailViewModel: CandyDetailViewModelType {
    func selectCandy() -> Candy? {
        return self.candyDataType?.getCandy()
    }
    
    func setUpByButton(buyButton: UIButton, isBuy: Bool) {
        buyButton.setTitle("Buy", for: .normal)
        buyButton.isHidden = isBuy
    }
}
