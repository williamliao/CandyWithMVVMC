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
    
    
    
    func getAllCandies() -> [Candy] {
        return [
            Candy(category:"Chocolate", name:"Chocolate Bar"),
            Candy(category:"Chocolate", name:"Chocolate Chip"),
            Candy(category:"Chocolate", name:"Dark Chocolate"),
            Candy(category:"Hard", name:"Lollipop"),
            Candy(category:"Hard", name:"Candy Cane"),
            Candy(category:"Hard", name:"Jaw Breaker"),
            Candy(category:"Other", name:"Caramel"),
            Candy(category:"Other", name:"Sour Chew"),
            Candy(category:"Other", name:"Gummi Bear"),
            Candy(category:"Other", name:"Candy Floss"),
            Candy(category:"Chocolate", name:"Chocolate Coin"),
            Candy(category:"Chocolate", name:"Chocolate Egg"),
            Candy(category:"Other", name:"Jelly Beans"),
            Candy(category:"Other", name:"Liquorice"),
            Candy(category:"Hard", name:"Toffee Apple")
        ]
    }
}


