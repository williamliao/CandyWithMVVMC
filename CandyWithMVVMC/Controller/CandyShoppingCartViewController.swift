//
//  CandyShoppingCartViewController.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/1/25.
//  Copyright © 2021 William. All rights reserved.
//

import UIKit

class CandyShoppingCartViewController: UIViewController, Storyboarded {
    
    var candyTableView: UITableView!
    
    var viewModel: CandyViewModelType!

    override func viewDidLoad() {
        super.viewDidLoad()
        render()
    }
    
    func render() {
        candyTableView = UITableView()
        self.view.backgroundColor = UIColor(red: 41.0/255.0, green: 42.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        candyTableView.backgroundColor = UIColor(red: 41.0/255.0, green: 42.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        
        let cartViewModel = CandyShoppingCartViewModel(viewModel: viewModel)
        
        cartViewModel.configureTableView(tableView: candyTableView, Add: view)
        
        cartViewModel.createBarItem(navItem: self.navigationItem)
        
        cartViewModel.makeDateSourceForTableView(tableView: candyTableView)
        
        viewModel.buyCandies.bind { [weak self] (_) in
            if #available(iOS 13.0, *) {
                cartViewModel.applyInitialSnapshots()
            } else {
                self?.candyTableView.reloadData()
            }
        }
        
        viewModel.verifyReceipt.bind { [weak self] (_) in
            if #available(iOS 13.0, *) {
                cartViewModel.applyInitialSnapshots()
            } else {
                self?.candyTableView.reloadData()
            }
        }
        
        viewModel.fetchVerifyReceipt()
        self.viewModel.getSubscriptions()
        
        candyTableView.register(CandyListTableViewCell.self,
            forCellReuseIdentifier: CandyListTableViewCell.reuseIdentifier
        )
    }

}
