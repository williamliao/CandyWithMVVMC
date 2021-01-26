//
//  CandyListCoordinator.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

class CandyListCoordinator: Coordinator {
    
    // MARK: - Properties
    let rootViewController: UITabBarController
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    let apiClient: ApiClient
    
    lazy var candyViewModel: CandyViewModel! = {
        let candyService = CandyApiService(apiClient: apiClient)
        let viewModel = CandyViewModel(service: candyService)
        return viewModel
    }()
    
    lazy var candyListViewModel: CandyListViewModel! = {
        let candyService = CandyApiService(apiClient: apiClient)
        let viewModel = CandyListViewModel(viewModel: candyViewModel)
        return viewModel
    }()
    
    lazy var candyDetailViewModel: CandyDetailViewModel! = {
        let viewdModel = CandyDetailViewModel()
        return viewdModel
    }()

    // MARK: - Coordinator
    init(rootViewController: UITabBarController, apiClient: ApiClient) {
        self.rootViewController = rootViewController
        self.apiClient = apiClient
    }
    
    override func start() {
        let list = createListView()
        let map = createMapView()
        let cart = createCartView()
        self.rootViewController.setViewControllers([list, map, cart], animated: false)
        
        if #available(iOS 13.0, *) {
            self.rootViewController.tabBar.items?[0].image = UIImage(systemName: "bag")?.withRenderingMode(.alwaysOriginal)
            self.rootViewController.tabBar.items?[0].selectedImage = UIImage(systemName: "bag.fill")?.withRenderingMode(.alwaysOriginal)
            
            self.rootViewController.tabBar.items?[1].image = UIImage(systemName: "map")?.withRenderingMode(.alwaysOriginal)
            self.rootViewController.tabBar.items?[1].selectedImage = UIImage(systemName: "map.fill")?.withRenderingMode(.alwaysOriginal)
            
            self.rootViewController.tabBar.items?[2].image = UIImage(systemName: "cart")?.withRenderingMode(.alwaysOriginal)
            self.rootViewController.tabBar.items?[2].selectedImage = UIImage(systemName: "cart.fill")?.withRenderingMode(.alwaysOriginal)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    override func finish() {
        
    }
    
    func createListView() -> UINavigationController {
        let candyListVC = CandyListViewController.instantiate()
        candyListVC.viewModel = candyViewModel
        candyListVC.candyListViewModel = candyListViewModel
        candyListViewModel.coordinator = self
        let nav = UINavigationController(rootViewController: candyListVC)
        return nav
    }
    
    func createMapView() -> UINavigationController {
        let candyMapVC = CandyMapViewController.instantiate()
        candyMapVC.viewModel = candyViewModel
        candyMapVC.title = "Map"
        let nav = UINavigationController(rootViewController: candyMapVC)
        return nav
    }
    
    func createCartView() -> UINavigationController {
        let candyCartVC = CandyShoppingCartViewController.instantiate()
        candyCartVC.viewModel = candyViewModel
        candyCartVC.title = "Cart"
        let nav = UINavigationController(rootViewController: candyCartVC)
        return nav
    }
}

extension CandyListCoordinator {
    func goToDetailView(candy: CandyDetailViewDataType) {
        candyDetailViewModel.candyDataType = candy
        let candyDetailVC = CandyDetailViewController.instantiate()
        candyDetailVC.viewModel = candyDetailViewModel
        candyDetailViewModel.coordinator = self

        if let currentNavController = self.rootViewController.selectedViewController as? UINavigationController {
            currentNavController.pushViewController(candyDetailVC, animated: true)
        }
    }
    
    func gobackToListView() {
        if let currentNavController = self.rootViewController.selectedViewController as? UINavigationController {
            currentNavController.popToRootViewController(animated: true)
        }
    }
    
    func candyDetailViewController(didBuy candy: inout Candy, amount: Double) {
        candyListViewModel.candyDidBuy(didBuy: &candy, amount: amount)
    }
}


