//
//  CandyListViewModel.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/1/13.
//  Copyright © 2021 William. All rights reserved.
//

import UIKit

enum Section: Int, CaseIterable, Hashable {
  case availableCandies
  case buyCandies
}


@available(iOS 13.0, tvOS 13.0, *)
typealias UserDataSource = UITableViewDiffableDataSource<Section, Item>

class CandyListViewModel: NSObject {
    
    var viewModel: CandyViewModel!
    private var searchFooter: SearchFooter!
    
    // MARK: - Properties
    fileprivate var isSearching: Bool = false
    var filterCandies: Observable<[Candy]> = Observable([])
    var buyCandies: Observable<Set<Candy>> = Observable(Set<Candy>())
    var filterBuyCandies: Observable<Set<Candy>> = Observable(Set<Candy>())
    
    @available(iOS 13.0, *)
    lazy var dataSource = UserDataSource()
    
    // MARK: - Types
   
    init(viewModel: CandyViewModel) {
        self.viewModel = viewModel
        super.init()
    }
}

extension CandyListViewModel: CandyListViewModelType { }

// MARK:- UITableViewDiffableDataSource methods
extension CandyListViewModel {
    
    @available(iOS 13.0, *)
    func getDatasource() -> UserDataSource {
        return dataSource
    }
   
    @available(iOS 13.0, *)
    func makeDataSource(tableView: UITableView) -> UITableViewDiffableDataSource<Section, Item> {

        return UITableViewDiffableDataSource<Section, Item>(tableView: tableView) { [self] (tableView, indexPath, items) -> CandyListTableViewCell? in
            let cell = self.configureCell(tableView: tableView, items: items, indexPath: indexPath)
            return cell
        }
    }

    @available(iOS 13.0, *)
    func applyInitialSnapshots() {
        let dataSource = getDatasource()
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        //Append available sections
        Section.allCases.forEach { snapshot.appendSections([$0]) }
        dataSource.apply(snapshot, animatingDifferences: false)
      
        //Append annotations to their corresponding sections
        if isSearching {
            filterCandies.value.forEach { (candy) in
                snapshot.appendItems([Item(candy: candy, title: candy.name)], toSection: .availableCandies)
            }
        } else {
            viewModel.candies.value.forEach { (candy) in
                snapshot.appendItems([Item(candy: candy, title: candy.name)], toSection: .availableCandies)
            }
        }
        
        if isSearching {
            filterBuyCandies.value.forEach { (candy) in
                snapshot.appendItems([Item(candy: candy, title: candy.name)], toSection: .buyCandies)
            }
        } else {
            buyCandies.value.forEach { (candy) in
                snapshot.appendItems([Item(candy: candy, title: candy.name)], toSection: .buyCandies)
            }
        }
        
        //Force the update on the main thread to silence a warning about tableview not being in the hierarchy!
        DispatchQueue.main.async {
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    @available(iOS 13.0, *)
    func updateDataSource(for candy: Candy) {
        let dataSource = getDatasource()
        var snapshot = dataSource.snapshot()
        let items = snapshot.itemIdentifiers
        let candyItem = items.first { item in
          item.candy == candy
        }
        
        if let candyItem = candyItem {
          // 3
          snapshot.reloadItems([candyItem])
          // 4
          dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
        }
    }
    
    @available(iOS 13.0, *)
    func remove(_ candy: Candy, animate: Bool = true) {
        let dataSource = getDatasource()
        var snapshot = dataSource.snapshot()
        
        let items = snapshot.itemIdentifiers
        let candyItem = items.first { item in
          item.candy == candy
        }
        
        if let candyItem = candyItem {
          snapshot.deleteItems([candyItem])
          dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
        }
    }
}

// MARK:- UITableViewDataSource methods
extension CandyListViewModel:  UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems(searchFooter: searchFooter, numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cellForRowAt(tableView: tableView, indexPath: indexPath, identifier: CandyListTableViewCell.reuseIdentifier)
        cell.selectionStyle = .none
        return cell
    }
    
    func candiesTitle(row: Int) -> String {
         return isSearching ? filterCandies.value[row].name : viewModel.candies.value[row].name
     }
     
     func candiesCategory(row: Int) -> String {
         return isSearching ? filterCandies.value[row].category.rawValue : viewModel.candies.value[row].category.rawValue
     }
     
     func numberOfItems(searchFooter: SearchFooter, numberOfRowsInSection section: Int) -> Int {
         
         if (viewModel.candies.value.count == 0) {
             return 0
         }

         if isSearching {
           searchFooter.setIsFilteringToShow(filteredItemCount:
                  filterCandies.value.count, of: viewModel.candies.value.count)
           return filterCandies.value.count
         }
         searchFooter.setNotFiltering()
        
        switch section {
            case 0:
                return isSearching ? filterCandies.value.count : viewModel.candies.value.count
            case 1:
                return isSearching ? filterBuyCandies.value.count : buyCandies.value.count
            default:
                return 0
        }
     }
     
     func cellForRowAt(tableView: UITableView, indexPath:IndexPath, identifier: String) -> UITableViewCell   {
         
        switch indexPath.section {
            case 0:
                let candy = isSearching ? filterCandies.value[indexPath.row] : viewModel.candies.value[indexPath.row]
                
                let items = Item(candy: candy, title: candy.name)
                
                let cell = self.configureCell(tableView: tableView, items: items, indexPath: indexPath)
               
                return cell ?? CandyListTableViewCell()
                
            case 1:
                let candy = isSearching ? Array(filterCandies.value)[indexPath.row] : Array(buyCandies.value)[indexPath.row]
                
                let items = Item(candy: candy, title: candy.name)
                
                let cell = self.configureCell(tableView: tableView, items: items, indexPath: indexPath)
                
                return cell ?? CandyListTableViewCell()
        default:
            return CandyListTableViewCell()
        }
     }
}

// MARK:- Common methods
extension CandyListViewModel {
    
    func shouldShowDiscount(row: Int) -> Bool {
        return isSearching ? filterCandies.value[row].shouldShowDiscount : viewModel.candies.value[row].shouldShowDiscount
    }
    
    func itemFor(row: Int) -> CandyDetailViewDataType  {
        let candy = isSearching ? filterCandies.value[row] : viewModel.candies.value[row]
        let dataType: CandyDetailViewDataType = CandyDetailViewData(candy: candy)
        return dataType
    }
    
    func configureCell(tableView: UITableView, items: Item, indexPath: IndexPath) -> CandyListTableViewCell? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CandyListTableViewCell.reuseIdentifier, for: indexPath) as? CandyListTableViewCell
        
        cell?.contentView.backgroundColor = UIColor(red: 41.0/255.0, green: 42.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        
        cell?.titleLabel.textColor = UIColor.white
        cell?.subTitleLabel.textColor = UIColor.lightGray
        cell?.amountLabel.textColor = UIColor.white
        
        cell?.titleLabel.backgroundColor = UIColor.clear
        cell?.subTitleLabel.backgroundColor = UIColor.clear
        cell?.amountLabel.backgroundColor = UIColor.clear
        
        let candyName = items.candy?.name
        cell?.titleLabel.text = candyName
        
        cell?.subTitleLabel.text = items.candy?.category.rawValue
        cell?.iconImageView.image = UIImage(named: candyName ?? "")
        
        if (items.candy?.amount == 0.0) {
            let shouldShowDiscount = items.candy?.shouldShowDiscount
            cell?.showShowDiscount(show: shouldShowDiscount ?? false)
        } else {
            cell?.showShowDiscount(show: false)
            
            guard let amount = items.candy?.amount  else {
                return cell
            }
            
            cell?.showAmount(show: amount > 0.0 ? true : false, amount: amount)
        }
        
        return cell
    }
    
    func makeDateSourceForTableView(tableView: UITableView) {
        if #available(iOS 13.0, *) {
            dataSource = self.makeDataSource(tableView: tableView)
            tableView.dataSource = dataSource
            
        } else {
            tableView.dataSource = self
            //tableView.delegate = self
        }
    }
    
    func titleForHeaderInSection(titleForHeaderInSection section: Int) -> String? {
        guard let sectionTitle = Section(rawValue: section) else {
          return nil
        }
        
        switch sectionTitle {
         // 2
         case .availableCandies:
            return "availableCandies"
         // 3
         case .buyCandies:
            return "buyCandies"
         }
    }
}

// MARK: - Search
extension CandyListViewModel {
    
    func setSearchFooter(searchFooter: SearchFooter) {
        self.searchFooter = searchFooter
    }
    
    func refreshFooterForDiffableDataSource() {
        
        if (viewModel.candies.value.count == 0) {
            return
        }

        if isSearching {
          searchFooter.setIsFilteringToShow(filteredItemCount:
                                                filterCandies.value.count + filterBuyCandies.value.count, of: viewModel.candies.value.count + buyCandies.value.count)
            return
        }
        searchFooter.setNotFiltering()
    }
    
    func searchFor(text: String,  category: Candy.Category) {

        filterContentForSearchText(text, category: category)

        if filterCandies.value.count > 0 || filterBuyCandies.value.count > 0 {
            isSearching = true
        } else {
            // 可加入一個查找不到的資料的label來告知使用者查不到資料...
        }
    }
    
    func didSelectRow(_ row: Int, from controller: UIViewController) {
       let candy = isSearching ? filterCandies.value[row] : viewModel.candies.value[row]
        viewModel.coordinatorDelegate?.didSelectCandy(row, candy: candy, from: controller)
    }
    
    func setDelegate(viewModel: CandyDetailViewModel) {
        viewModel.delegate = self
    }
    
    func didSelectClose(from controller: UIViewController) {
        
    }
    
    func didCloseSearchFunction() {
        isSearching = false
        filterCandies.value = [Candy]()
        filterBuyCandies.value = Set<Candy>()
    }
    
    func didChangeSelectedScopeButtonIndex(scopeButtonTitle: String, searchText:String) {
        let category = Candy.Category(rawValue:scopeButtonTitle)
        filterContentForSearchText(searchText, category: category)
    }
    
    func filterContentForSearchText(_ searchText: String,
                                    category: Candy.Category? = nil) {
        
        filterCandies.value = viewModel.candies.value.filter { (candy: Candy) -> Bool in
            filterNameKeyword(candy: candy, searchText: searchText, category: category)
        }
        
        filterBuyCandies.value = buyCandies.value.filter { (candy: Candy) -> Bool in
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

// MARK: - CandyDetailViewControllerDelegate
extension CandyListViewModel: CandyDetailViewControllerDelegate {
    
    func candyDetailViewController(didBuy candy: inout Candy, amount: Double) {
        
        if #available(iOS 13.0, *) {
            candy.amount = amount
            buyCandies.value.insert(candy)
            let dataSource = getDatasource()
            var snapshot = dataSource.snapshot()
            let sectionIdentifiers = dataSource.snapshot().sectionIdentifiers[Section.buyCandies.rawValue]
            let items = snapshot.itemIdentifiers(inSection: sectionIdentifiers)
            
            let newItem = items.first { item in
              item.candy == candy
            }
            
            if let candyItem = newItem {
                snapshot.appendItems([candyItem])
                DispatchQueue.main.async {
                    dataSource.apply(snapshot, animatingDifferences: false)
                }
            }
            updateDataSource(for: candy)
        } else {
            candy.amount = amount
            buyCandies.value.insert(candy)
        }
    }
}
