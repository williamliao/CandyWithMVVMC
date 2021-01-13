//
//  CandyLocation.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/1/13.
//  Copyright © 2021 William. All rights reserved.
//

import Foundation

struct CandyLocation: Decodable {
  let title: String
  let locationName: String
  let coordinate: Coordinate
}

struct Coordinate: Decodable {
  let latitude: Double
  let longitude: Double
}

extension CandyLocation {
  static func candyLocation() -> [CandyLocation] {
    guard
      let url = Bundle.main.url(forResource: "candyShop", withExtension: "json"),
      let data = try? Data(contentsOf: url)
      else {
        return []
    }
    
    do {
      let decoder = JSONDecoder()
      return try decoder.decode([CandyLocation].self, from: data)
    } catch {
      return []
    }
  }
}
