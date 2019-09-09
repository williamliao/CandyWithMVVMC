//
//  CandyDetailViewData.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

struct CandyDetailViewData {
    
    private let candy: Candy

    init(candy: Candy) {
        self.candy = candy
    }
}

extension CandyDetailViewData: CandyDetailViewDataType {
    func shouldShowDisconunt() -> Bool {
        return true
    }
    
    func candyColor() -> UIColor {
        return UIColor.white
    }
    
    func getCandy() -> Candy {
        return self.candy
    }
    
    
}
