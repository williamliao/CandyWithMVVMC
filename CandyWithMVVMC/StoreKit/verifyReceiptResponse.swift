//
//  verifyReceiptResponse.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/2/2.
//  Copyright © 2021 William. All rights reserved.
//

import Foundation

struct VerifyReceiptResponse: Codable {
    let status: Int
    let environment: String
    let receipt: Receipt
    let latest_receipt_info: [Latest_receipt_info]
    let latest_receipt: String
    let pending_renewal_info: [Pending_renewal_info]
}
