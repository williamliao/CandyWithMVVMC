//
//  AppCoordinator.swift
//  HelloCoordinator
//
//  Created by William on 2018/12/25.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
    // MARK: - Properties
    let window: UIWindow?
    
  //  var navigationController: UINavigationController
//    lazy var rootViewController: UINavigationController = {
//        return UINavigationController()
//    }()
    
    var tabController: UITabBarController
    lazy var rootViewController: UITabBarController = {
        return UITabBarController()
    }()
 
    let apiClient: ApiClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json; charset=utf-8"]
        let apiClient = ApiClient(configuration: configuration)
        return apiClient
    }()
    
    // MARK: - Coordinator
    init(tabController: UITabBarController, window: UIWindow?) {
        self.tabController = tabController
        self.window = window
    }
    
    override func start() {
       // guard let navigationController = navigationController else { return }
        let coordinator = CandyListCoordinator(rootViewController: tabController, apiClient: apiClient)
        coordinator.start()
    }
    
    override func finish() {
        
    }
}
