//
//  CandyViewData.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

struct CandyViewData {
    
    private let candy: [Candy]
    
    init(candy: [Candy]) {
        self.candy = candy
    }
}

extension CandyViewData : CandyViewDataType {
    
    var candies: [Candy] {
        return candy
    }

    var shouldShowDisconunt: Bool {
        return true
    }
    
    var candyColor: UIColor {
        return UIColor.white
    }
}
