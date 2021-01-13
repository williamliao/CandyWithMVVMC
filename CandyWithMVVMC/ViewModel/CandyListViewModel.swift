//
//  CandyListViewModel.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/1/13.
//  Copyright © 2021 William. All rights reserved.
//

import UIKit

class CandyListViewModel: NSObject {
    // MARK: - Properties
    
    fileprivate var isSearching: Bool = false
    
    var viewModel: CandyViewModel!
    
    init(viewModel: CandyViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    var filterCandies: Observable<[Candy]> = Observable([])
}

extension CandyListViewModel: CandyListViewModelType {
    
    func candiesTitle(row: Int) -> String {
        return isSearching ? filterCandies.value[row].name : viewModel.candies.value[row].name
    }
    
    func candiesCategory(row: Int) -> String {
        return isSearching ? filterCandies.value[row].category.rawValue : viewModel.candies.value[row].category.rawValue
    }
    
    func numberOfItems(searchFooter: SearchFooter) -> Int {
        
        if (viewModel.candies.value.count == 0) {
            return 0
        }

        if isSearching {
          searchFooter.setIsFilteringToShow(filteredItemCount:
                 filterCandies.value.count, of: viewModel.candies.value.count)
          return filterCandies.value.count
        }
        searchFooter.setNotFiltering()
        
        return viewModel.candies.value.count
    }
    
    func itemFor(row: Int) -> CandyDetailViewDataType  {
        let candy = isSearching ? filterCandies.value[row] : viewModel.candies.value[row]
        let dataType: CandyDetailViewDataType = CandyDetailViewData(candy: candy)
        return dataType
    }
    
    func cellForRowAt(tableView: UITableView, row:Int, identifier: String) -> UITableViewCell   {
        
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) else {
                return UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: identifier)
            }
            return cell
        }()
        
        cell.contentView.backgroundColor = UIColor(red: 41.0/255.0, green: 42.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.detailTextLabel?.textColor = UIColor.white
        cell.detailTextLabel?.backgroundColor = UIColor.clear
        
        let candyName = self.candiesTitle(row: row)
        cell.textLabel?.text = candyName
        
        cell.detailTextLabel?.text = self.candiesCategory(row: row)
        cell.imageView?.image = UIImage(named: candyName)
        return cell
    }
    
    func searchFor(text: String,  category: Candy.Category) {

        filterContentForSearchText(text, category: category)

        if filterCandies.value.count > 0 {
            isSearching = true
        } else {
            // 可加入一個查找不到的資料的label來告知使用者查不到資料...
        }
    }
    
    func didSelectRow(_ row: Int, from controller: UIViewController) {
       let candy = isSearching ? filterCandies.value[row] : viewModel.candies.value[row]
        viewModel.coordinatorDelegate?.didSelectCandy(row, candy: candy, from: controller)
    }
    
    func didSelectClose(from controller: UIViewController) {
        
    }
    
    func didCloseSearchFunction() {
        isSearching = false
        filterCandies.value = [Candy]()
    }
    
    func didChangeSelectedScopeButtonIndex(scopeButtonTitle: String, searchText:String) {
        let category = Candy.Category(rawValue:scopeButtonTitle)
        filterContentForSearchText(searchText, category: category)
    }
    
    func filterContentForSearchText(_ searchText: String,
                                    category: Candy.Category? = nil) {
        
        filterCandies.value = viewModel.candies.value.filter { (candy: Candy) -> Bool in
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
}
