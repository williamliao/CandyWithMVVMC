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
        //viewModel.coordinatorDelegate = self
        return viewModel
    }()
    
    lazy var candyListViewModel: CandyListViewModel! = {
        let candyService = CandyApiService(apiClient: apiClient)
        let viewModel = CandyListViewModel(viewModel: candyViewModel)
        //viewModel.coordinatorDelegate = self
        return viewModel
    }()
    
    lazy var candyDetailViewModel: CandyDetailViewModel! = {
        let viewdModel = CandyDetailViewModel()
        //viewModel.coordinatorDelegate = self
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
        self.rootViewController.setViewControllers([list, map], animated: false)
    }
    
    override func finish() {
        
    }
    
    func createListView() -> UINavigationController {
        let candyListVC = CandyListViewController.instantiate()
        candyListVC.viewModel = candyViewModel
        candyListVC.candyListViewModel = candyListViewModel
        //candyListVC.coordinator = self
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
}

extension CandyListCoordinator {
    func goToDetailView(candy: CandyDetailViewDataType) {
        candyDetailViewModel.candyDataType = candy
        let candyDetailVC = CandyDetailViewController.instantiate()
        candyDetailVC.viewModel = candyDetailViewModel
        candyDetailViewModel.coordinator = self
        candyListViewModel.setDelegate(viewModel: candyDetailViewModel)
        //candyDetailViewModel.delegate = self
        
        if let currentNavController = self.rootViewController.selectedViewController as? UINavigationController {
            currentNavController.pushViewController(candyDetailVC, animated: true)
        }
    }
    
    func gobackToListView() {
        if let currentNavController = self.rootViewController.selectedViewController as? UINavigationController {
            currentNavController.popToRootViewController(animated: true)
        }
    }
}


