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
    
    func createListView() -> CandyListViewController {
        let candyListVC = CandyListViewController.instantiate()
        candyListVC.viewModel = candyViewModel
        candyListVC.candyListViewModel = candyListViewModel
        candyListVC.coordinator = self
        return candyListVC
    }
    
    func createMapView() -> CandyMapViewController {
        let candyMapVC = CandyMapViewController.instantiate()
        candyMapVC.viewModel = candyViewModel
        candyMapVC.title = "Map"
        return candyMapVC
    }
}

extension CandyListCoordinator {
    func goToDetailView(candy: CandyDetailViewDataType, from controller: UIViewController) {
        candyDetailViewModel.candyDataType = candy
        let candyDetailVC = CandyDetailViewController.instantiate()
        candyDetailVC.viewModel = candyDetailViewModel
        let nav:UINavigationController = self.rootViewController.viewControllers![0] as! UINavigationController
        nav.pushViewController(candyDetailVC, animated: true)
    }
}


