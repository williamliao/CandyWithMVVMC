//
//  CandyDetailViewController.swift
//  HelloViper
//
//  Created by William on 2018/12/4.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit


class CandyDetailViewController: UIViewController, Storyboarded {
  
    var isBuy = false
    
    var viewModel: CandyDetailViewModelType! {
        didSet {
            viewModel.viewDelegate = self
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.start()
        self.view.backgroundColor = UIColor(red: 41.0/255.0, green: 42.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        setNavTitle()
    }
    
    func setNavTitle() {
        guard let candy = viewModel.selectCandy() else {
            return
        }
        title = candy.category.rawValue
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
    }
}

extension CandyDetailViewController : CandyDetailViewModelViewDelegate {
    func updateScreen() {
        viewModel.createView(Add: self.view)
        viewModel.createAmoutView(Add: self.view)
        viewModel.configureView()
        viewModel.setUpByButton(isBuy: isBuy)
    }
}
