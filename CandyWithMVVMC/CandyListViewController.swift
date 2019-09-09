//
//  CandyListViewController.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

class CandyListViewController: UIViewController, Storyboarded {
    @IBOutlet var candyTableView: UITableView!
    
    var coordinator :CandyListCoordinator?
    
    var viewModel: CandyViewModelType! {
        didSet {
            viewModel.coordinatorDelegate = self
            render()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 41.0/255.0, green: 42.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        candyTableView.backgroundColor = UIColor(red: 41.0/255.0, green: 42.0/255.0, blue: 48.0/255.0, alpha: 1.0)
    }
    
    func render() {
        viewModel.viewDelegate = self
        
    }
}

extension CandyListViewController: CandyViewModelViewDelegate {
    func updateScreen() {
        weak var weakSelf = self
        DispatchQueue.main.async {
            weakSelf?.candyTableView.reloadData()
        }
    }
}

extension CandyListViewController: CandyViewModelCoordinatorDelegate {
    func didSelectCandy(_ row: Int, candy: Candy, from controller: UIViewController) {
        let candy = viewModel.itemFor(row: row)
        coordinator?.goToDetailView(candy: candy, from: self)
    }
}


extension CandyListViewController:  UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CandyCell") else {
                // Never fails:
                return UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "CandyCell")
            }
            return cell
        }()
        
        cell.contentView.backgroundColor = UIColor(red: 41.0/255.0, green: 42.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.detailTextLabel?.textColor = UIColor.white
        cell.detailTextLabel?.backgroundColor = UIColor.clear
        
        let nameArray = viewModel.getAllCandies().compactMap({$0.name})
        let categoryArray = viewModel.getAllCandies().compactMap({$0.category})
        cell.textLabel?.text = nameArray[indexPath.row]
        cell.detailTextLabel?.text = categoryArray[indexPath.row]
        cell.imageView?.image = UIImage(named: nameArray[indexPath.row])
        return cell
    }
}

extension CandyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(indexPath.row, from: self)
    }
}



