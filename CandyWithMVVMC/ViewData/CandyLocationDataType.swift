//
//  CandyLocationDataType.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/1/13.
//  Copyright © 2021 William. All rights reserved.
//

import Foundation

protocol CandyLocationDataType {

    var candyLocations: [CandyLocation] { get }
    
    var shouldShowDisconunt: Bool { get }
}
