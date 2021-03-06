//
//  SearchViewController.swift
//  CandyWithMVVMC
//
//  Created by William on 2020/12/25.
//  Copyright © 2020 William. All rights reserved.
//

import UIKit

class SearchViewController: UISearchController {
    
    var viewModel: CandyViewModelType!
    
    var searchViewModel: CandySearchViewModel!
    
    private var searchFooter: SearchFooter!
 
    var isSearchBarEmpty: Bool {
        return self.searchBar.text?.isEmpty ?? true
    }

    var isFiltering: Bool {
        let searchBarScopeIsFiltering = self.searchBar.selectedScopeButtonIndex != 0
        return self.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }

    init(viewModel: CandyViewModelType) {
        self.viewModel = viewModel
        super.init(searchResultsController: nil)
        if #available(iOS 12.0, *) {
            self.setViewModel(viewModel: viewModel)
        }
    }
    
    //For Below iOS 13 with UISearchController SubClass
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        searchViewModel = CandySearchViewModel(viewModel: self.viewModel)
        searchViewModel.setSearchFooter(searchFooter: searchFooter)
        self.searchResultsUpdater = self
        self.searchBar.delegate = self
        self.searchBar.sizeToFit()
        self.obscuresBackgroundDuringPresentation = false
        self.searchBar.placeholder = "Search Candies"
        definesPresentationContext = false
        self.searchBar.scopeButtonTitles = Candy.Category.allCases.map { $0.rawValue }
    }
    
    func setSearchFooter(searchFooter: SearchFooter) {
        self.searchFooter = searchFooter
    }
    
    func setViewModel(viewModel: CandyViewModelType) {
        self.viewModel = viewModel
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        if searchController.searchBar.text.isEmptyOrWhitespace() {
            return
        }
        
        guard let searchText = searchController.searchBar.text else {
            return
        }
        
        let searchBar = searchController.searchBar
        let category = Candy.Category(rawValue:
          searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        
        self.searchViewModel.searchFor(text: searchText, category: category!)
    }
}

extension SearchViewController :UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        closeSearchView()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            closeSearchView()
        }
    }
    
    func closeSearchView() {
        //self.searchBar.showsScopeBar = false
        self.searchViewModel.didCloseSearchFunction()
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
      let category = Candy.Category(rawValue:
        searchBar.scopeButtonTitles![selectedScope])
        self.searchViewModel.searchFor(text: searchBar.text!, category: category!)
    }
}
