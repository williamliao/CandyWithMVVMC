//
//  CandyViewModel.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

class CandyViewModel:NSObject {
    weak var coordinatorDelegate: CandyViewModelCoordinatorDelegate?
    //weak var viewDelegate: CandyViewModelViewDelegate?

    // MARK: - Properties
    
    var candies: Observable<[Candy]> = Observable([])
    var filterCandies: Observable<[Candy]> = Observable([])
    var errorMessage: Observable<String?> = Observable(nil)
    var error: Observable<Error?> = Observable(nil)
    
    fileprivate let service: CandyService
    
   // fileprivate var candies: [Candy] = []
    
    //fileprivate var filterCandies: [Candy] = []
    
    fileprivate var isSearching: Bool = false
    
//    var isFiltering: Bool {
//      return searchController.isActive && !isSearchBarEmpty
//    }
    
    init(service: CandyService) {
        self.service = service
        super.init()
       /* service.getCandy(withText: "Test") { [weak self] (result) in
            switch result {
            case .value(let candyViewData):
                let candyViewDataType: CandyViewDataType = candyViewData
                self?.candiesO = Observable(candyViewDataType.candies)
                self?.candies = candyViewDataType.candies
                self?.viewDelegate?.updateScreen()
            case .error(let error):
                print(error)
                break
            }
        }*/
        
        
    }
    
    func fetchCandies() {
        self.service.getCandy(withText: "Test") { [weak self] (result) in
            switch result {
            case .value(let candyViewData):
                let candyViewDataType: CandyViewDataType = candyViewData
                
                self?.candies.value = candyViewDataType.candies
               // self?.viewDelegate?.updateScreen()
            case .error(let error):
                self?.setError(error)
                break
            }
        }
    }
    
    func setError(_ error: Error) {
        self.errorMessage = Observable(error.localizedDescription)
        self.error = Observable(error)
    }
}

extension CandyViewModel: CandyViewModelType {
    
//    func getAllCandies() -> [Candy] {
//        return isSearching ? filterCandies : candies
//    }
    
    func candiesTitle(row: Int) -> String {
        return isSearching ? filterCandies.value[row].name : candies.value[row].name
    }
    
    func candiesCategory(row: Int) -> String {
        return isSearching ? filterCandies.value[row].category.rawValue : candies.value[row].category.rawValue
    }
    
    func numberOfItems(searchFooter: SearchFooter) -> Int {
        
        if isSearching {
          searchFooter.setIsFilteringToShow(filteredItemCount:
                 filterCandies.value.count, of: candies.value.count)
          return filterCandies.value.count
        }
        searchFooter.setNotFiltering()
        return candies.value.count
        
        //return isSearching ? filterCandies.count : candies.count
    }
    
    func itemFor(row: Int) -> CandyDetailViewDataType  {
        let candy = isSearching ? filterCandies.value[row] : candies.value[row]
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
        let candy = isSearching ? filterCandies.value[row] : candies.value[row]
        coordinatorDelegate?.didSelectCandy(row, candy: candy, from: controller)
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
        
        filterCandies.value = candies.value.filter { (candy: Candy) -> Bool in
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


