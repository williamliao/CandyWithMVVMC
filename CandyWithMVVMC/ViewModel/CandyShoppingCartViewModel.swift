//
//  CandyShoppingCartViewModel.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/1/25.
//  Copyright © 2021 William. All rights reserved.
//

import UIKit
import StoreKit

enum CandyShoppingCartSection: Int, CaseIterable, Hashable {
  case main
}

class CandyShoppingCartViewModel: NSObject {
    
    var viewModel: CandyViewModelType!
    
    @available(iOS 13.0, *)
    lazy var dataSource  = makeDataSource(tableView: UITableView())
    
    init(viewModel: CandyViewModelType) {
        self.viewModel = viewModel
    }

}

// MARK:- View methods
extension CandyShoppingCartViewModel {
    func configureTableView(tableView: UITableView, Add to: UIView) {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        to.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: to.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: to.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: to.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: to.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

// MARK:- Cell methods
extension CandyShoppingCartViewModel {
    
    @available(iOS 13.0, *)
    func getDatasource() -> GenericDiffableDataSource<CandyShoppingCartSection, Item> {
        return dataSource
    }
    
    @available(iOS 13.0, *)
    func makeDataSource(tableView: UITableView) -> GenericDiffableDataSource<CandyShoppingCartSection, Item> {
        
        return GenericDiffableDataSource<CandyShoppingCartSection, Item>(tableView: tableView) {  [self] (tableView, indexPath, items) -> CandyListTableViewCell? in
            let cell = self.configureCell(tableView: tableView, items: items, indexPath: indexPath)
            return cell
        }
    }
    
    @available(iOS 13.0, *)
    func applyInitialSnapshots() {
        let dataSource = getDatasource()
        var snapshot = NSDiffableDataSourceSnapshot<CandyShoppingCartSection, Item>()
        
        //Append available sections
        CandyShoppingCartSection.allCases.forEach { snapshot.appendSections([$0]) }
        dataSource.apply(snapshot, animatingDifferences: false)
      
        //Append annotations to their corresponding sections
        viewModel.buyCandies.value.forEach { (candy) in
            snapshot.appendItems([Item(candy: candy, candyProducts: viewModel.recipeProducts.value)], toSection: .main)
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
        
        let shouldShowDiscount = items.candy?.shouldShowDiscount
        
        guard let amount = items.candy?.amount, let isPurchased = items.candy?.isPurchased   else {
            return cell
        }
        
        if isPurchased {
            cell?.showShowDiscount(show: false)
        } else {
            cell?.showShowDiscount(show: shouldShowDiscount ?? false)
        }
        
        cell?.showAmount(show: isPurchased ? true : false, amount: amount)
        
        return cell
    }
    
    func makeDateSourceForTableView(tableView: UITableView) {
        if #available(iOS 13.0, *) {
            dataSource = self.makeDataSource(tableView: tableView)
            
            tableView.dataSource = dataSource
            
        } else {
            //tableView.dataSource = self
        }
    }
}


