//
//  receiptData.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/2/2.
//  Copyright © 2021 William. All rights reserved.
//

import Foundation

struct AutoSubscriptionStatus {
    var receiptData: String? {
      guard
      let url = Bundle.main.appStoreReceiptURL,
      let data = try? Data(contentsOf: url)
      else { return nil }
      return data.base64EncodedString()
    }
    
    var receiptPassword: String? {
        return "79b4e6583c2...ca7d504ed97"
    }
}

extension AutoSubscriptionStatus {
  static func getVerifyReceipt() -> VerifyReceiptResponse? {
    guard
      let url = Bundle.main.url(forResource: "verifyReceiptResponse", withExtension: "json"),
      let data = try? Data(contentsOf: url)
      else {
        return nil
    }
    
    do {
      let decoder = JSONDecoder()
      return try decoder.decode(VerifyReceiptResponse.self, from: data)
    } catch {
      return nil
    }
  }
    
   /* static func getVerifyReceipt() -> [String]? {
        guard let url = Bundle.main.url(forResource: "verifyReceiptResponse", withExtension: "plist") else { return nil }
        do {
            
//            let data = try Data(contentsOf: url)
//            let decoder = PropertyListDecoder()
//            return try decoder.decode(VerifyReceiptResponse.self, from: data)
            
            let data = try Data(contentsOf: url)
            let productIDs = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] ?? []
            return productIDs
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }*/
}


