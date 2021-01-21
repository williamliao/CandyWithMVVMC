//
//  CandyListViewModel.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/1/13.
//  Copyright © 2021 William. All rights reserved.
//

import UIKit

class CandyListViewModel: NSObject {
    
    var viewModel: CandyViewModel!
    private var searchFooter: SearchFooter!
    
    // MARK: - Properties
    fileprivate var isSearching: Bool = false
    var filterCandies: Observable<[Candy]> = Observable([])
    var buyCandies: Observable<Set<Candy>> = Observable(Set<Candy>())
    var dataSource: UITableViewDiffableDataSource<Section, Item>!

    // MARK: - Types
    enum Section: Int, CaseIterable, Hashable {
      case availableCandies
      case buyCandies
    }
  
    init(viewModel: CandyViewModel) {
        self.viewModel = viewModel
        super.init()
    }
}

// MARK: - Cell
extension CandyListViewModel: CandyListViewModelType {
    
   /* func candiesTitle(row: Int) -> String {
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
    } */
    
    /*func cellForRowAt(tableView: UITableView, row:Int, identifier: String) -> UITableViewCell   {
        
        let cell: CandyListTableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) else {
                return CandyListTableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: identifier)
            }
            return cell as? CandyListTableViewCell ?? CandyListTableViewCell()
        }()
        
        cell.contentView.backgroundColor = UIColor(red: 41.0/255.0, green: 42.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        
        cell.titleLabel.textColor = UIColor.white
        cell.subTitleLabel.textColor = UIColor.lightGray
        
        cell.titleLabel.backgroundColor = UIColor.clear
        cell.subTitleLabel.backgroundColor = UIColor.clear
        
        let candyName = self.candiesTitle(row: row)
        cell.titleLabel.text = candyName
        
        cell.subTitleLabel.text = self.candiesCategory(row: row)
        cell.iconImageView.image = UIImage(named: candyName)
        
        let shouldShowDiscount = self.shouldShowDiscount(row: row)
        cell.showShowDiscount(show: shouldShowDiscount)
        return cell
    }*/
    
    func shouldShowDiscount(row: Int) -> Bool {
        return isSearching ? filterCandies.value[row].shouldShowDiscount : viewModel.candies.value[row].shouldShowDiscount
    }
    
    func itemFor(row: Int) -> CandyDetailViewDataType  {
        let candy = isSearching ? filterCandies.value[row] : viewModel.candies.value[row]
        let dataType: CandyDetailViewDataType = CandyDetailViewData(candy: candy)
        return dataType
    }
    
    func makeDataSource(tableView: UITableView) -> UITableViewDiffableDataSource<Section, Item> {
        
        let datasource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) { [self] (tableView, indexPath, items) -> CandyListTableViewCell? in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CandyListTableViewCell.reuseIdentifier, for: indexPath) as? CandyListTableViewCell
            self.configureCell(cell: cell ?? CandyListTableViewCell(), items: items)
            return cell
        }
        
        return datasource
    }
    
    func configureCell(cell:CandyListTableViewCell, items: Item) {
        
        cell.contentView.backgroundColor = UIColor(red: 41.0/255.0, green: 42.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        
        cell.titleLabel.textColor = UIColor.white
        cell.subTitleLabel.textColor = UIColor.lightGray
        
        cell.titleLabel.backgroundColor = UIColor.clear
        cell.subTitleLabel.backgroundColor = UIColor.clear
        
        let candyName = items.candy?.name
        cell.titleLabel.text = candyName
        
        cell.subTitleLabel.text = items.candy?.category.rawValue
        cell.iconImageView.image = UIImage(named: candyName ?? "")
        
        let shouldShowDiscount = items.candy?.shouldShowDiscount
        cell.showShowDiscount(show: shouldShowDiscount ?? false)
    }
    
    func makeDateSourceForTableView(tableView: UITableView) {
        dataSource = self.makeDataSource(tableView: tableView)
        tableView.dataSource = dataSource
    }
    
    func applyInitialSnapshots() {
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
        
        buyCandies.value.forEach { (candy) in
            snapshot.appendItems([Item(candy: candy, title: candy.name)], toSection: .buyCandies)
        }
        
        //Force the update on the main thread to silence a warning about tableview not being in the hierarchy!
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    func updateDataSource(for candy: Candy) {
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
    
    func remove(_ candy: Candy, animate: Bool = true) {
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
    
    func numberOfItems() {
        
        if (viewModel.candies.value.count == 0) {
            return
        }

        if isSearching {
          searchFooter.setIsFilteringToShow(filteredItemCount:
                 filterCandies.value.count, of: viewModel.candies.value.count)
            return
        }
        searchFooter.setNotFiltering()
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
    
    func setDelegate(vc: CandyDetailViewController) {
        vc.delegate = self
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
        applyInitialSnapshots()
        numberOfItems()
    }
}

// MARK: - CandyDetailViewControllerDelegate
extension CandyListViewModel: CandyDetailViewControllerDelegate {
    func candyDetailViewController(_ candyDetailViewController: CandyDetailViewController, didBuy candy: Candy) {
        
        buyCandies.value.insert(candy)
        
        var snapshot = dataSource.snapshot()
        let sectionIdentifiers = dataSource.snapshot().sectionIdentifiers[Section.buyCandies.rawValue]
        let items = snapshot.itemIdentifiers(inSection: sectionIdentifiers)
        
        let newItem = items.first { item in
          item.candy == candy
        }
        
        if let candyItem = newItem {
            snapshot.appendItems([candyItem])
            DispatchQueue.main.async {
                self.dataSource.apply(snapshot, animatingDifferences: false)
            }
        }
        updateDataSource(for: candy)
    }
}
