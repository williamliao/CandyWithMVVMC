//
//  CandyListViewController.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

class CandyListViewController: UIViewController, Storyboarded {
    @IBOutlet var candyTableView: UITableView!
    @IBOutlet var searchFooter: SearchFooter!
    @IBOutlet var searchFooterBottomConstraint: NSLayoutConstraint!
    
    var coordinator :CandyListCoordinator?
    
    var viewModel: CandyViewModelType!
    var candyListViewModel: CandyListViewModelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 41.0/255.0, green: 42.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        candyTableView.backgroundColor = UIColor(red: 41.0/255.0, green: 42.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        
        render()
        createSearchViewController()
        addKeyBoardObserver()
    }
  
    func render() {
        
        self.candyListViewModel.makeDateSourceForTableView(tableView: candyTableView)
        
        viewModel.candies.bind { [weak self] (_) in
            if #available(iOS 13.0, *) {
                self?.candyListViewModel.applyInitialSnapshots()
            } else {
                self?.candyTableView.reloadData()
            }
        }
        
        viewModel.filterCandies.bind { [weak self] (_) in
            if #available(iOS 13.0, *) {
                self?.candyListViewModel.applyInitialSnapshots()
            } else {
                self?.candyTableView.reloadData()
            }
        }
        
        viewModel.buyCandies.bind { [weak self] (_) in
            if #available(iOS 13.0, *) {
                self?.candyListViewModel.applyInitialSnapshots()
            } else {
                self?.candyTableView.reloadData()
            }
        }

        viewModel.error.bind { (error) in
            guard let error = error else {
                return
            }
            
            print("error = \(error.localizedDescription)")
            
            //show Error View
        }
        
        self.viewModel.fetchCandies()
        self.viewModel.getProducts()
        candyTableView.estimatedSectionHeaderHeight = 60
        candyTableView.separatorStyle = .none
        candyTableView.separatorColor = UIColor.clear
        
        candyTableView.register(CandyListTableViewCell.self,
            forCellReuseIdentifier: CandyListTableViewCell.reuseIdentifier
        )
        
        candyTableView.register(CandyListTableViewCell.self,
            forCellReuseIdentifier: CandyListTableViewCell.reuseIdentifier
        )
        
        self.title = "CandyShop"
        let nav = self.navigationController?.navigationBar
        nav?.tintColor = UIColor(red: 41.0/255.0, green: 42.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    func createSearchViewController() {
        let searchController = SearchViewController(viewModel: viewModel)
        
        //let searchController = UISearchController(searchResultsController: nil)
        searchController.setSearchFooter(searchFooter: searchFooter)
        if #available(iOS 11.0, *) {
            
            self.navigationItem.searchController = searchController
            searchController.hidesNavigationBarDuringPresentation = false
        } else {
            candyTableView.tableHeaderView = searchController.searchBar
        }
        
        //candyTableView.sectionHeaderHeight = UITableView.automaticDimension
    }
    
    func addKeyBoardObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil, queue: .main) { (notification) in
                                        self.handleKeyboard(notification: notification) }
        notificationCenter.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                       object: nil, queue: .main) { (notification) in
                                        self.handleKeyboard(notification: notification) }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK:- Keyboard

extension CandyListViewController {
    
    func handleKeyboard(notification: Notification) {
      // 1
      guard notification.name == UIResponder.keyboardWillChangeFrameNotification else {
        searchFooterBottomConstraint.constant = 0
        view.layoutIfNeeded()
        return
      }
      
      guard
        let info = notification.userInfo,
        let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
          return
      }
      
      // 2
      let keyboardHeight = keyboardFrame.cgRectValue.size.height
      UIView.animate(withDuration: 0.1, animations: { () -> Void in
        self.searchFooterBottomConstraint.constant = keyboardHeight
        self.view.layoutIfNeeded()
      })
    }
}
