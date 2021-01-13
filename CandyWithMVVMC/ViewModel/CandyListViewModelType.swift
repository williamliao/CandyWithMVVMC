//
//  CandyListViewModelType.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/1/13.
//  Copyright © 2021 William. All rights reserved.
//

import UIKit

protocol CandyListViewModelType {
    
    //var candies: Observable<[Candy]> { get  set }
    var filterCandies: Observable<[Candy]> { get  set }
  
    func candiesTitle(row: Int) -> String
    func candiesCategory(row: Int) -> String

    func numberOfItems(searchFooter: SearchFooter) -> Int
    
    func cellForRowAt(tableView: UITableView, row:Int, identifier: String) -> UITableViewCell
    
    func itemFor(row: Int) -> CandyDetailViewDataType
   
    func searchFor(text: String,  category: Candy.Category)
    
    func didSelectRow(_ row: Int, from controller: UIViewController)
    
    func didSelectClose(from controller: UIViewController)
    
    func didCloseSearchFunction()
}
