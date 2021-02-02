/*
 //
 //  In_app.swift
 //  CandyWithMVVMC
 //
 //  Created by William on 2021/2/2.
 //  Copyright © 2021 William. All rights reserved.
 //
*/

struct In_app: Codable {
	let quantity: String
	let product_id: String
	let transaction_id: String
	let original_transaction_id: String
	let purchase_date: String
	let purchase_date_ms: String
	let purchase_date_pst: String
	let original_purchase_date: String
	let original_purchase_date_ms: String
	let original_purchase_date_pst: String
	let expires_date: String
	let expires_date_ms: String
	let expires_date_pst: String
	let web_order_line_item_id: String
	let is_trial_period: String
	let is_in_intro_offer_period: String
}
