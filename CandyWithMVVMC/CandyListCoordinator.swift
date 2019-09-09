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
    
    let rootViewController: UINavigationController
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    let apiClient: ApiClient
    
    lazy var candyListViewModel: CandyViewModel! = {
        let candyService = CandyApiService(apiClient: apiClient)
        let viewModel = CandyViewModel(service: candyService)
        //viewModel.coordinatorDelegate = self
        return viewModel
    }()
    
    lazy var candyDetailViewModel: CandyDetailViewModel! = {
        let viewdModel = CandyDetailViewModel()
        //viewModel.coordinatorDelegate = self
        return viewdModel
    }()

    // MARK: - Coordinator
    init(rootViewController: UINavigationController, apiClient: ApiClient) {
        self.rootViewController = rootViewController
        self.apiClient = apiClient
    }
    
    override func start() {
        let candyListVC = CandyListViewController.instantiate()
        candyListVC.viewModel = candyListViewModel
        candyListVC.coordinator = self
        self.rootViewController.setViewControllers([candyListVC], animated: false)
    }
    
    override func finish() {
        
    }
}

extension CandyListCoordinator {
    func goToDetailView(candy: CandyDetailViewDataType, from controller: UIViewController) {
        candyDetailViewModel.candyDataType = candy
        let candyDetailVC = CandyDetailViewController.instantiate()
        candyDetailVC.viewModel = candyDetailViewModel
        self.rootViewController.pushViewController(candyDetailVC, animated: true)
    }
}


