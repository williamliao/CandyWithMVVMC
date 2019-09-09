//
//  CandyViewDataType.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

protocol CandyViewDataType {
    
//    var name: String { get }
//    
//    var category: String { get }
    
    var candies: [Candy] { get }
    
    var shouldShowDisconunt: Bool { get }
    
    var candyColor: UIColor { get }
    
}

