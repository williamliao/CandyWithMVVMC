//
//  ApiClient.swift
//  HelloCoordinator
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit
import Combine

enum Result<T> {
    case value(T)
    case error(Error)
}

struct BaseUrl {
    #if DEBUG
        static let candy: String = "https://sandbox.candy.willliam.org"
        static let verifyReceipt: String = "https://sandbox.itunes.apple.com"
    #else
        static let candy: String = "https://candy.willliam.org"
        static let verifyReceipt: String = "https://buy.itunes.apple.com"
    #endif
}

struct Endpoint {
    static let candy: String = "/get"
    static let verifyReceipt: String = "/verifyReceipt"
}

enum ApiResult<T> {
    case success(T)
    case failed(Error)
}

enum verifyReceiptError: Error {
    case noneRespone
    case unknown
}

class ApiClient: NSObject {
    
    var urlSession = URLSession.shared
    
    private let candyModel = CandyModel()
    private var cancellable: AnyCancellable?
  
    typealias JSONTaskCompletionHandler = (ApiResult<CandyViewData>) -> Void
    
    typealias JSONLocationTaskCompletionHandler = (ApiResult<CandyLocationViewData>) -> Void
    
    typealias JSONVerifyReceiptTaskCompletionHandler = (ApiResult<VerifyReceiptResponse>) -> Void
    
    var configuration: URLSessionConfiguration?
    
    init(configuration: URLSessionConfiguration) {
        self.configuration = configuration
    }
 
    func GET(endpoint: String, params: Dictionary<String, Any>, completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {
        
        let baseURL = URL.init(string: BaseUrl.candy)!
    
        let url = URL.init(string: endpoint, relativeTo: baseURL)
        let dataTask = urlSession.dataTask(with: url!, completionHandler: { [weak self] (data, response, error) in
            
            let candies = self?.getAllCandies()
 
            let candiesSource = CandyViewData(candy: candies!)
            completion(ApiResult.success(candiesSource))
        })
        
        
        return dataTask
    }
    
    func getLocations(endpoint: String, params: Dictionary<String, Any>, completion: @escaping JSONLocationTaskCompletionHandler) -> URLSessionDataTask {
        
        let baseURL = URL.init(string: "https://httpbin.org")!
    
        let url = URL.init(string: endpoint, relativeTo: baseURL)
        let dataTask = urlSession.dataTask(with: url!, completionHandler: { [weak self] (data, response, error) in
            
            let candyLocation = self?.getAllCandyLocation()
 
            let candiesSource = CandyLocationViewData(candyLocation: candyLocation!)
            completion(ApiResult.success(candiesSource))
        })
        
        return dataTask
    }
    
    func getInAppSubscriptionStatus(completion: @escaping JSONVerifyReceiptTaskCompletionHandler) -> URLSessionDataTask {
        let status = AutoSubscriptionStatus()
        
        let baseURL = URL.init(string: BaseUrl.verifyReceipt)!
        let endpoint = Endpoint.verifyReceipt
        let url = URL.init(string: endpoint, relativeTo: baseURL)
        
        let parameterDict = ["password": status.receiptPassword, "receipt-data": status.receiptData]
        
        let body = try? JSONSerialization.data(withJSONObject: parameterDict, options: [.fragmentsAllowed])
        
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        request.httpBody = body
        let dataTask = urlSession.dataTask(with: request as URLRequest) { [weak self] (data, response, error) in
            
//            guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
//                print("error")
//                return
//            }
            
            let respone = self?.getVerifyReceipt()
            
            guard let verifyReceipt = respone  else {
                completion(ApiResult.failed(verifyReceiptError.noneRespone))
                return
            }
            
            completion(ApiResult.success(verifyReceipt))
        }
        return dataTask
    }
    
    func getAllCandies() -> [Candy] {
        
        return Candy.candies()
    }
    
    func getAllCandyLocation() -> [CandyLocation] {
        return CandyLocation.candyLocation()
    }
    
    func getVerifyReceipt() -> VerifyReceiptResponse? {
        return AutoSubscriptionStatus.getVerifyReceipt()
    }
    
    
}
