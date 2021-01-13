//
//  ApiClient.swift
//  HelloCoordinator
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

enum Result<T> {
    case value(T)
    case error(Error)
}

struct Endpoint {
    static let candy: String = "/get"
}

enum ApiResult<T> {
    case success(T)
    case failed(Error)
}

class ApiClient: NSObject {

    typealias JSONTaskCompletionHandler = (ApiResult<CandyViewData>) -> Void
    typealias JSONLocationTaskCompletionHandler = (ApiResult<CandyLocationViewData>) -> Void
    
    var configuration: URLSessionConfiguration?
    
    init(configuration: URLSessionConfiguration) {
        self.configuration = configuration
    }
 
    func GET(endpoint: String, params: Dictionary<String, Any>, completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {
        
        let baseURL = URL.init(string: "https://httpbin.org")!
    
        let url = URL.init(string: endpoint, relativeTo: baseURL)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!, completionHandler: { [weak self] (data, response, error) in
            
            let candies = self?.getAllCandies()
 
            let candiesSource = CandyViewData(candy: candies!)
            completion(ApiResult.success(candiesSource))
        })
        
        
        return dataTask
    }
    
    func getLocations(endpoint: String, params: Dictionary<String, Any>, completion: @escaping JSONLocationTaskCompletionHandler) -> URLSessionDataTask {
        
        let baseURL = URL.init(string: "https://httpbin.org")!
    
        let url = URL.init(string: endpoint, relativeTo: baseURL)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!, completionHandler: { [weak self] (data, response, error) in
            
            let candyLocation = self?.getAllCandyLocation()
 
            let candiesSource = CandyLocationViewData(candyLocation: candyLocation!)
            completion(ApiResult.success(candiesSource))
        })
        
        return dataTask
    }
    
    func getAllCandies() -> [Candy] {
        return Candy.candies()
    }
    
    func getAllCandyLocation() -> [CandyLocation] {
        return CandyLocation.candyLocation()
    }
}


