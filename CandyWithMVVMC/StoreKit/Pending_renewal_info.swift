/*
 //
 //  Pending_renewal_info.swift
 //  CandyWithMVVMC
 //
 //  Created by William on 2021/2/2.
 //  Copyright © 2021 William. All rights reserved.
 //
*/

struct Pending_renewal_info: Codable {
	let expiration_intent: String
	let auto_renew_product_id: String
	let original_transaction_id: String
	let is_in_billing_retry_period: String
	let product_id: String
	let auto_renew_status: String
}
