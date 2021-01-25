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

class CandyListViewModel: NSObject {
    
    var viewModel: CandyViewModel!
    var coordinator :CandyListCoordinator?
   // private var searchFooter: SearchFooter!
    
    // MARK: - Properties
  //  fileprivate var isSearching: Bool = false
//    var filterCandies: Observable<[Candy]> = Observable([])
//    var filterBuyCandies: Observable<Set<Candy>> = Observable(Set<Candy>())
   // var buyCandies: Observable<Set<Candy>> = Observable(Set<Candy>())
    
    @available(iOS 13.0, *)
    lazy var dataSource  = makeDataSource(tableView: UITableView())
    
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
    func getDatasource() -> CandyDiffableDataSource<Section, Item> {
        return dataSource
    }
   
    @available(iOS 13.0, *)
    func makeDataSource(tableView: UITableView) -> CandyDiffableDataSource<Section, Item> {
        
        return CandyDiffableDataSource<Section, Item>(tableView: tableView) {  [self] (tableView, indexPath, items) -> CandyListTableViewCell? in
            let cell = self.configureCell(tableView: tableView, items: items, indexPath: indexPath)
            return cell
        }
        
        /*
        return UITableViewDiffableDataSource<Section, Item>(tableView: tableView) { [self] (tableView, indexPath, items) -> CandyListTableViewCell? in
            let cell = self.configureCell(tableView: tableView, items: items, indexPath: indexPath)
            return cell
        }*/
    }

    @available(iOS 13.0, *)
    func applyInitialSnapshots() {
        let dataSource = getDatasource()
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        //Append available sections
        Section.allCases.forEach { snapshot.appendSections([$0]) }
        dataSource.apply(snapshot, animatingDifferences: false)
      
        //Append annotations to their corresponding sections
        if viewModel.isSearching.value {
            viewModel.filterCandies.value.forEach { (candy) in
                snapshot.appendItems([Item(candy: candy, title: candy.name)], toSection: .availableCandies)
            }
        } else {
            viewModel.candies.value.forEach { (candy) in
                snapshot.appendItems([Item(candy: candy, title: candy.name)], toSection: .availableCandies)
            }
        }
        
        if viewModel.isSearching.value {
            viewModel.filterBuyCandies.value.forEach { (candy) in
                snapshot.appendItems([Item(candy: candy, title: candy.name)], toSection: .buyCandies)
            }
        } else {
            viewModel.buyCandies.value.forEach { (candy) in
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

@available(iOS 13.0, tvOS 13.0, *)
open class CandyDiffableDataSource<SectionIdentifierType, ItemIdentifierType>: UITableViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
    where SectionIdentifierType : Hashable, ItemIdentifierType : Hashable {
    
    public typealias SectionTitleProvider = (UITableView, SectionIdentifierType) -> String?
    
    open var sectionTitleProvider: SectionTitleProvider?
    open var useSectionIndex: Bool = false
    
    open override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard useSectionIndex, let sectionTitleProvider = sectionTitleProvider else { return nil }
        return snapshot().sectionIdentifiers.compactMap { sectionTitleProvider(tableView, $0) }
    }
    
    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = "\(self.snapshot().sectionIdentifiers[section])"
        return title
    }

    open override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard useSectionIndex else { return 0 }
        return snapshot().sectionIdentifiers.firstIndex(where: { sectionTitleProvider?(tableView, $0) == title }) ?? 0
    }
}

// MARK:- UITableViewDataSource methods
extension CandyListViewModel:  UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems(numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cellForRowAt(tableView: tableView, indexPath: indexPath, identifier: CandyListTableViewCell.reuseIdentifier)
        cell.selectionStyle = .none
        return cell
    }
    
     func cellForRowAt(tableView: UITableView, indexPath:IndexPath, identifier: String) -> UITableViewCell   {
        
        switch indexPath.section {
            case 0:
                let candy = viewModel.isSearching.value ? viewModel.filterCandies.value[indexPath.row] : viewModel.candies.value[indexPath.row]
                
                let items = Item(candy: candy, title: candy.name)
                
                let cell = self.configureCell(tableView: tableView, items: items, indexPath: indexPath)
               
                return cell ?? CandyListTableViewCell()
                
            case 1:
                let candy = viewModel.isSearching.value ? Array(viewModel.filterCandies.value)[indexPath.row] : Array(viewModel.buyCandies.value)[indexPath.row]
                
                let items = Item(candy: candy, title: candy.name)
                
                let cell = self.configureCell(tableView: tableView, items: items, indexPath: indexPath)
                
                return cell ?? CandyListTableViewCell()
        default:
            return CandyListTableViewCell()
        }
     }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = titleForHeaderInSection(titleForHeaderInSection: section)
        return title
    }
    
    
    private func titleForHeaderInSection(titleForHeaderInSection section: Int) -> String? {
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
    
    
    private func candiesTitle(row: Int) -> String {
        return viewModel.isSearching.value ? viewModel.filterCandies.value[row].name : viewModel.candies.value[row].name
     }
     
    private func candiesCategory(row: Int) -> String {
        return viewModel.isSearching.value ? viewModel.filterCandies.value[row].category.rawValue : viewModel.candies.value[row].category.rawValue
     }
    
    private func numberOfItems(numberOfRowsInSection section: Int) -> Int {
         
         if (viewModel.candies.value.count == 0) {
             return 0
         }

      /*  if viewModel.isSearching.value {
           searchFooter.setIsFilteringToShow(filteredItemCount:
                                                viewModel.filterCandies.value.count, of: viewModel.candies.value.count)
            return viewModel.filterCandies.value.count
         }
         searchFooter.setNotFiltering() */
        
        switch section {
            case 0:
                return viewModel.isSearching.value ? viewModel.filterCandies.value.count : viewModel.candies.value.count
            case 1:
                return viewModel.isSearching.value ? viewModel.filterBuyCandies.value.count : viewModel.buyCandies.value.count
            default:
                return 0
        }
     }
}

// MARK:- UITableViewDelegate methods

extension CandyListViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRow(indexPath.row)
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}


// MARK:- Common methods
extension CandyListViewModel {
    
//    func setDelegate(viewModel: CandyDetailViewModel) {
//        viewModel.delegate = self
//    }

    func shouldShowDiscount(row: Int) -> Bool {
        return viewModel.isSearching.value ? viewModel.filterCandies.value[row].shouldShowDiscount : viewModel.candies.value[row].shouldShowDiscount
    }
    
    func itemFor(row: Int) -> CandyDetailViewDataType  {
        let candy = viewModel.isSearching.value ? viewModel.filterCandies.value[row] : viewModel.candies.value[row]
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
        }
        tableView.delegate = self
    }
}

// MARK:- CandyViewModelCoordinatorDelegate methods
extension CandyListViewModel {
    func didSelectRow(_ row: Int) {
        let candy = itemFor(row: row)
        coordinator?.goToDetailView(candy: candy)
    }
}

// MARK:- Candy Did Buy methods
extension CandyListViewModel {
    func candyDidBuy(didBuy candy: inout Candy, amount: Double) {
       
        if #available(iOS 13.0, *) {
            candy.amount = amount
            viewModel.buyCandies.value.insert(candy)
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
            viewModel.buyCandies.value.insert(candy)
        }
    }
}
