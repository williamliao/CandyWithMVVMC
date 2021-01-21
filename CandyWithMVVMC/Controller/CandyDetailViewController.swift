//
//  CandyDetailViewController.swift
//  HelloViper
//
//  Created by William on 2018/12/4.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

protocol CandyDetailViewControllerDelegate: class {
  func candyDetailViewController(_ candyDetailViewController: CandyDetailViewController, didBuy candy: Candy)
}

class CandyDetailViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var candyImage: UIImageView!
    @IBOutlet weak var candyNameLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var adoptButton: UIButton!
    
    weak var delegate: CandyDetailViewControllerDelegate?
    
    var isBuy = false
    
    var viewModel: CandyDetailViewModelType! {
        didSet {
            viewModel.viewDelegate = self
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.start()
        
        adoptButton.addTarget(self, action: #selector(didTapAdoptButton), for: .touchUpInside)
        
        self.view.backgroundColor = UIColor(red: 41.0/255.0, green: 42.0/255.0, blue: 48.0/255.0, alpha: 1.0)
    }
}

extension CandyDetailViewController : CandyDetailViewModelViewDelegate {
    func updateScreen() {
        if let descriptionLabel = candyNameLbl, let detailDescriptionLabel = categoryLbl, let candyImageView = candyImage {
            
            guard let candy = viewModel.selectCandy() else {
                return
            }
            descriptionLabel.text = candy.name
            detailDescriptionLabel.text = candy.category.rawValue
            candyImageView.image = UIImage(named: candy.name)
            title = candy.category.rawValue
            
            viewModel.setUpByButton(buyButton: adoptButton, isBuy: isBuy)
            
        }
    }
}

// MARK: - IBActions
extension CandyDetailViewController {
  @IBAction func didTapAdoptButton(_ sender: UIButton) {
    
    guard let candy = viewModel.selectCandy() else {
        return
    }
    
    delegate?.candyDetailViewController(self, didBuy: candy)
    navigationController?.popViewController(animated: true)
  }
}
