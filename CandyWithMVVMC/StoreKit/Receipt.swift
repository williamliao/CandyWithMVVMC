/*
 //
 //  Receipt.swift
 //  CandyWithMVVMC
 //
 //  Created by William on 2021/2/2.
 //  Copyright © 2021 William. All rights reserved.
 //
*/

struct Receipt: Codable {
	let receipt_type: String
	let adam_id: Int
	let app_item_id: Int
	let bundle_id: String
	let application_version: String
	let download_id: Int
	let version_external_identifier: Int
	let receipt_creation_date: String
	let receipt_creation_date_ms: String
	let receipt_creation_date_pst: String
	let request_date: String
	let request_date_ms: String
	let request_date_pst: String
	let original_purchase_date: String
	let original_purchase_date_ms: String
	let original_purchase_date_pst: String
	let original_application_version: String
	let in_app: [In_app]
}
