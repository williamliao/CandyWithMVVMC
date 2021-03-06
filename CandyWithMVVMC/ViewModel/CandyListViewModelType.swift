//
//  CandyListViewModelType.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/1/13.
//  Copyright © 2021 William. All rights reserved.
//

import UIKit

protocol CandyListViewModelType {

    func itemFor(row: Int) -> CandyDetailViewDataType
 
    func didSelectRow(_ row: Int)

    func makeDateSourceForTableView(tableView: UITableView)
    
    @available(iOS 13.0, *)
    func applyInitialSnapshots()
    
    func candyDidBuy(didBuy item: Item, amount: Double)
    
    func restorePurchases()
    
    func createBarItem(navItem: UINavigationItem)
    
    @available(iOS 13.0, *)
    func updateDataSource(for candy: Candy)
}
