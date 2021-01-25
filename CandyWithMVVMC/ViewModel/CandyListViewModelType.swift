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

    func setDelegate(viewModel: CandyDetailViewModel)
    
    func makeDateSourceForTableView(tableView: UITableView)
    
    func titleForHeaderInSection(titleForHeaderInSection section: Int) -> String?
    
    @available(iOS 13.0, *)
    func applyInitialSnapshots()
}
