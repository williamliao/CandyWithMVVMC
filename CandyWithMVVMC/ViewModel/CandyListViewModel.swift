//
//  CandyListViewModel.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/1/13.
//  Copyright © 2021 William. All rights reserved.
//

import UIKit
import StoreKit

enum Section: Int, CaseIterable, Hashable {
  case availableCandies
  case buyCandies
}

class CandyListViewModel: NSObject {
    
    var viewModel: CandyViewModel!
    var coordinator :CandyListCoordinator?

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
    func getDatasource() -> GenericDiffableDataSource<Section, Item> {
        return dataSource
    }
   
    @available(iOS 13.0, *)
    func makeDataSource(tableView: UITableView) -> GenericDiffableDataSource<Section, Item> {
        
        return GenericDiffableDataSource<Section, Item>(tableView: tableView) {  [self] (tableView, indexPath, items) -> CandyListTableViewCell? in
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
                snapshot.appendItems([Item(candy: candy, candyProducts: viewModel.recipeProducts.value, subscriptions: nil)], toSection: .availableCandies)
            }
        } else {
            
            viewModel.candies.value.forEach { (candy) in
                snapshot.appendItems([Item(candy: candy, candyProducts: viewModel.recipeProducts.value, subscriptions: nil)], toSection: .availableCandies)
            }
        }
        
        if viewModel.isSearching.value {
            viewModel.filterBuyCandies.value.forEach { (candy) in
                snapshot.appendItems([Item(candy: candy, candyProducts: viewModel.recipeProducts.value, subscriptions: nil)], toSection: .buyCandies)
            }
        } else {
            viewModel.buyCandies.value.forEach { (candy) in
                snapshot.appendItems([Item(candy: candy, candyProducts: viewModel.recipeProducts.value, subscriptions: nil)], toSection: .buyCandies)
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
                
                let items = Item(candy: candy, candyProducts: viewModel.recipeProducts.value, subscriptions: nil)
                
                let cell = self.configureCell(tableView: tableView, items: items, indexPath: indexPath)
               
                return cell ?? CandyListTableViewCell()
                
            case 1:
                let candy = viewModel.isSearching.value ? Array(viewModel.filterCandies.value)[indexPath.row] : Array(viewModel.buyCandies.value)[indexPath.row]
                
                let items = Item(candy: candy, candyProducts: viewModel.recipeProducts.value, subscriptions: nil)
                
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
        
        if #available(iOS 13.0, *) {
            
            guard let item = dataSource.itemIdentifier(for: indexPath) else {
              return
            }
            let dataType: CandyDetailViewDataType = CandyDetailViewData(item: item)
            coordinator?.goToDetailView(candy: dataType)
        } else {
            didSelectRow(indexPath.row)
        }
        
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
        let dataType: CandyDetailViewDataType = CandyDetailViewData(item: Item(candy: candy, candyProducts: self.viewModel.recipeProducts.value, subscriptions: nil))
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
        
        //let product = self.viewModel.getProduct(with: items.candy?.productID)
       // print("localizedTitle \(product?.localizedTitle)")
        
        let candyName = items.candy?.name
        cell?.titleLabel.text = candyName
        
        cell?.subTitleLabel.text = items.candy?.category.rawValue
        cell?.iconImageView.image = UIImage(named: candyName ?? "")
        
        let shouldShowDiscount = items.candy?.shouldShowDiscount
        
        guard let amount = items.candy?.amount, let isPurchased = items.candy?.isPurchased   else {
            return cell
        }
        
        if isPurchased {
            if (indexPath.section == 0) {
                cell?.showShowDiscount(show: shouldShowDiscount ?? false)
            } else {
                cell?.showShowDiscount(show: false)
            }
        } else {
            cell?.showShowDiscount(show: shouldShowDiscount ?? false)
        }
        
        cell?.showAmount(show: indexPath.section == 1 ? true : false, amount: amount)
        
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
    func candyDidBuy(didBuy item: inout Item, amount: Double) {
       
        if #available(iOS 13.0, *) {
           
            guard let candy = item.candy else {
                return
            }

            if candy.isPurchased {
                return
            }

            //viewModel.candies.value.filter ({ $0.productID == candy.productID }).forEach { $0.isPurchased = true }
            
            self.viewModel.buyCandies.value.insert(candy)
            
            if let recipeProduct = viewModel.getProduct(with: candy.productID) {
               
                buyCandies(using: recipeProduct, amount: amount) { (success) in
                    print("success \(success)")
                    
                    if (success) {
                        
                    } else {
                        self.viewModel.buyCandies.value.remove(candy)
                        self.coordinator?.showError(title: "", message: "The transaction could not be completed.")
                    }
                    
                }
                
            }
         
            
        } else {
            
            guard var candy = item.candy else {
                return
            }
            
            candy.amount = amount
            viewModel.buyCandies.value.insert(candy)
        }
    }
    
    func buyCandies(using product: SKProduct?,amount: Double, completion: @escaping (_ success: Bool) -> Void) {
        guard let product = product else { return }
       
        IAPManager.shared.buyWithMulitAmount(product: product, amount: Int(amount)) { (iapResult) in
            switch iapResult {
                case .success(let success):
                    if success {
                        let candy = self.viewModel.buyCandies.value.filter({ $0.productID == product.productIdentifier }).first
                        
                        guard let buyCandy = candy else {
                            return
                        }
                        
                        self.viewModel.markAsPurchased(true, candy: buyCandy, amount:amount)
                        
                        self.updateDataSource(for: buyCandy)
                    }
                    completion(true)
                case .failure(let error):
                    print(error)
                    completion(false)
            }
        }
    }
}
