//
//  CandyService.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

protocol CandyService {
   
    func getCandy(withText text: String, completion: @escaping (Result<CandyViewData>) -> Void)
    func getCandyLocation(withText text: String, completion: @escaping (Result<CandyLocationViewData>) -> Void)
    func getVerifyReceipt(completion: @escaping (Result<VerifyReceiptResponse>) -> Void)
}

class CandyApiService {
    let apiClient: ApiClient
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
}

extension CandyApiService: CandyService {
    func getCandy(withText text: String, completion: @escaping (Result<CandyViewData>) -> Void) {
        let endpoint = Endpoint.candy
        let params = ["q": text]
    
        let task = apiClient.GET(endpoint: endpoint, params: params) { (result: ApiResult<CandyViewData>) in
            switch result {
            case .success(let candy):
                completion(Result.value(candy))
            case .failed(let error):
                completion(Result.error(error))
                break
            }
        }
        task.resume()
    }
    
    func getCandyLocation(withText text: String, completion: @escaping (Result<CandyLocationViewData>) -> Void) {
        let endpoint = Endpoint.candy
        let params = ["q": text]
    
        let task = apiClient.getLocations(endpoint: endpoint, params: params) { (result: ApiResult<CandyLocationViewData>) in
            switch result {
            case .success(let candyLocation):
                completion(Result.value(candyLocation))
            case .failed(let error):
                completion(Result.error(error))
                break
            }
        }
        task.resume()
    }
    
    func getVerifyReceipt(completion: @escaping (Result<VerifyReceiptResponse>) -> Void) {
        let task = apiClient.getInAppSubscriptionStatus { (result: ApiResult<VerifyReceiptResponse>) in
            switch result {
            case .success(let verifyReceipt):
                completion(Result.value(verifyReceipt))
            case .failed(let error):
                completion(Result.error(error))
                break
            }
        }
        task.resume()
    }
    
}


