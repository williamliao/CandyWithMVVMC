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
  case subscriptions
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
    
    func createBarItem(navItem: UINavigationItem) {
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTapped))
        navItem.setRightBarButton(refresh, animated: true)
    }
    
    @objc func refreshTapped() {
        IAPManager.shared.restorePurchases { (result) in
            switch result {
                case .success(let products):
                    print("restorePurchases success \(products)")
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
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
            snapshot.appendItems([Item(candy: candy, candyProducts: viewModel.recipeProducts.value, subscriptions: nil)], toSection: .main)
        }
        
        if let verifyReceipt = viewModel.verifyReceipt.value {
            snapshot.appendItems([Item(candy: nil, candyProducts: nil, subscriptions: verifyReceipt)], toSection: .subscriptions)
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
        
        if (indexPath.section == 0) {
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
        } else {
            
            cell?.titleLabel.text = items.subscriptions?.receipt.in_app[indexPath.row].product_id
            
            let active: Bool = items.subscriptions?.receipt.in_app.count ?? 0 > 0 ? true : false
            
            cell?.subTitleLabel.text = active ? "Subscription Active" : "Subscription Un Active"
            
            cell?.iconImageView.image = active ? UIImage(systemName: "creditcard.fill") : UIImage(systemName: "creditcard")
            cell?.showShowDiscount(show: false)
            
            guard let quantity = items.subscriptions?.receipt.in_app[indexPath.row].quantity, let amount = Double(quantity)   else {
                return cell
            }
            
            cell?.showAmount(show: true, amount: amount)
        }
        
        return cell
    }
    
    func makeDateSourceForTableView(tableView: UITableView) {
        if #available(iOS 13.0, *) {
            dataSource = self.makeDataSource(tableView: tableView)
            
            tableView.dataSource = dataSource
            
        } else {
            //tableView.dataSource = self
        }
        
        tableView.delegate = self
    }
}

extension CandyShoppingCartViewModel {
    func tapBuySubscription(identifier: String) {
        //let identifiers: Set<String> = ["com.app.premium.monthly","com.app.premium.annual"]
        if let recipeProduct = viewModel.getSubscription(with: identifier) {
            buySubscription(using: recipeProduct) { (success) in
                
                if (success) {
                    
                } else {
                    //self.coordinator?.showError(title: "", message: "The transaction could not be completed.")
                }
            }
        }
    }
    
    func buySubscription(using product: SKProduct?, completion: @escaping (_ success: Bool) -> Void) {
        guard let product = product else { return }
       
        IAPManager.shared.buyAutoSubscriptionsProudcts(product: product) { (iapResult) in
            switch iapResult {
                case .success(let success):
                    if success {
                        let status = self.viewModel.verifyReceipt.value?.status == 0 ? true : false
                        
                        if (status) {
                            //markAsPurchased
                            
                            //self.updateDataSource()
                        }
                    }
                    completion(true)
                case .failure(let error):
                    print(error)
                    completion(false)
            }
        }
    }
}

// MARK:- UITableViewDelegate methods

extension CandyShoppingCartViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
          return
        }
        
        tapBuySubscription(identifier: item.subscriptions?.receipt.in_app[indexPath.row].product_id ?? "")
        
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
