//
//  CandyLocationViewData.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/1/13.
//  Copyright © 2021 William. All rights reserved.
//

import UIKit

struct CandyLocationViewData {
    
    internal let candyLocation: [CandyLocation]
    
    init(candyLocation: [CandyLocation]) {
        self.candyLocation = candyLocation
    }
}

extension CandyLocationViewData : CandyLocationDataType {
    
    var candyLocations: [CandyLocation] {
        return candyLocation
    }

    var shouldShowDisconunt: Bool {
        return true
    }
}
