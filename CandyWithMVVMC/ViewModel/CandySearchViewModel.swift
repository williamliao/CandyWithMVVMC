//
//  CandySearchViewModel.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/1/22.
//  Copyright © 2021 William. All rights reserved.
//

import UIKit

class CandySearchViewModel: NSObject {
    
    // MARK: - Properties
    //fileprivate var isSearching: Bool = false
    private var searchFooter: SearchFooter!
    var viewModel: CandyViewModelType!
    
    init(viewModel: CandyViewModelType) {
        self.viewModel = viewModel
    }
}

// MARK: - Search
extension CandySearchViewModel {
    
    func setSearchFooter(searchFooter: SearchFooter) {
        self.searchFooter = searchFooter
    }
    
    func refreshFooterForDiffableDataSource() {
        
        if (viewModel.candies.value.count == 0) {
            return
        }

        if viewModel.isSearching.value {
            searchFooter.setIsFilteringToShow(filteredItemCount:
                                                viewModel.filterCandies.value.count + viewModel.filterBuyCandies.value.count, of: viewModel.candies.value.count + viewModel.buyCandies.value.count)
            return
        }
        searchFooter.setNotFiltering()
    }
    
    func searchFor(text: String,  category: Candy.Category) {

        filterContentForSearchText(text, category: category)

        if viewModel.filterCandies.value.count > 0 || viewModel.filterBuyCandies.value.count > 0 {
            viewModel.isSearching.value = true
        } else {
            // 可加入一個查找不到的資料的label來告知使用者查不到資料...
        }
    }
    
    func didSelectClose(from controller: UIViewController) {
        
    }
    
    func didCloseSearchFunction() {
        viewModel.isSearching.value = false
        viewModel.filterCandies.value = [Candy]()
        viewModel.filterBuyCandies.value = Set<Candy>()
        refreshFooterForDiffableDataSource()
    }
    
    func didChangeSelectedScopeButtonIndex(scopeButtonTitle: String, searchText:String) {
        let category = Candy.Category(rawValue:scopeButtonTitle)
        filterContentForSearchText(searchText, category: category)
    }
    
    func filterContentForSearchText(_ searchText: String,
                                    category: Candy.Category? = nil) {
        
        viewModel.filterCandies.value = viewModel.candies.value.filter { (candy: Candy) -> Bool in
            filterNameKeyword(candy: candy, searchText: searchText, category: category)
        }
        
        viewModel.filterBuyCandies.value = viewModel.buyCandies.value.filter { (candy: Candy) -> Bool in
            filterNameKeyword(candy: candy, searchText: searchText, category: category)
        }
        refreshFooterForDiffableDataSource()
    }
    
    func filterNameKeyword(candy: Candy, searchText: String, category: Candy.Category? = nil) -> Bool {
        let doesCategoryMatch = category == .all || candy.category == category
        
        let isSearchBarEmpty: Bool = searchText.isEmpty
        
        if isSearchBarEmpty {
          return doesCategoryMatch
        } else {
          return doesCategoryMatch && candy.name.lowercased()
            .contains(searchText.lowercased())
        }
    }
}
