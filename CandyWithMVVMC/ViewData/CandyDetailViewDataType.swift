//
//  CandyDetailViewDataType.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

protocol CandyDetailViewDataType {
    
    func getItem() -> Item
   
    func shouldShowDisconunt() -> Bool
    
    func candyColor() -> UIColor
    
}

