//
//  CandyDetailViewData.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

struct CandyDetailViewData {
    
    private let item: Item

    init(item: Item) {
        self.item = item
    }
}

extension CandyDetailViewData: CandyDetailViewDataType {
    func shouldShowDisconunt() -> Bool {
        return true
    }
    
    func candyColor() -> UIColor {
        return UIColor.white
    }
    
    func getItem() -> Item {
        return self.item
    }
    
    
}
