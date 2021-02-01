//
//  CandyDetailViewModel.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit
import StoreKit

class CandyDetailViewModel {

    var coordinator :CandyListCoordinator?
    
    var candy: Candy?
    
    var candyDataType: CandyDetailViewDataType?
    
    var amountLabel: UILabel = UILabel()
    var amoutSetpper: UIStepper!
    
    var candyImage: UIImageView!
    var candyNameLbl: UILabel!
    var categoryLbl: UILabel!
    var buyButton: UIButton!
    
    private var product: SKProduct?
}

extension CandyDetailViewModel: CandyDetailViewModelType {
    
    func selectItem() -> Item? {
        return self.candyDataType?.getItem()
    }
    
    func setUpByButton(isBuy: Bool) {
        buyButton.setTitle("Buy", for: .normal)
        buyButton.setTitleColor(UIColor.systemBlue, for: .normal)
        buyButton.backgroundColor = UIColor.white
        buyButton.isHidden = isBuy
        buyButton.addTarget(self, action: #selector(didTapBuyButton), for: .touchUpInside)
    }
}

extension CandyDetailViewModel {
    
    @objc func didTapBuyButton() {
        
        guard var item = selectItem() else {
            return
        }
        
        coordinator?.checkWantBuyAlert(item: item,amount:amoutSetpper.value , completionClosure: { [weak self] (_) in
            self?.coordinator?.gobackToListView()
            self?.coordinator?.candyDetailViewController(didBuy: &item, amount: (self?.amoutSetpper.value)!)
        })
    }
    
    @IBAction func didTapAmountStepperValueChanged(_ sender: UIStepper) {
        amountLabel.text = "數量 \(Int(sender.value).description)"
    }
    
    func createView(Add to: UIView) {
        
        candyImage = UIImageView()
        candyNameLbl = UILabel()
        categoryLbl = UILabel()
        buyButton = UIButton()
        
        candyNameLbl.textColor = UIColor.white
        categoryLbl.textColor = UIColor.white
        
        candyNameLbl.textAlignment = .center
        categoryLbl.textAlignment = .center
        
        candyImage.translatesAutoresizingMaskIntoConstraints = false
        candyNameLbl.translatesAutoresizingMaskIntoConstraints = false
        categoryLbl.translatesAutoresizingMaskIntoConstraints = false
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        
        to.addSubview(candyImage)
        to.addSubview(candyNameLbl)
        to.addSubview(categoryLbl)
        to.addSubview(buyButton)
        
        NSLayoutConstraint.activate([
            candyImage.topAnchor.constraint(equalTo: to.safeAreaLayoutGuide.topAnchor, constant: 20),
            candyImage.centerXAnchor.constraint(equalTo: to.safeAreaLayoutGuide.centerXAnchor),
            
            candyNameLbl.leadingAnchor.constraint(equalTo: to.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            candyNameLbl.trailingAnchor.constraint(equalTo: to.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            candyNameLbl.topAnchor.constraint(equalTo: candyImage.bottomAnchor, constant: 10),
            candyNameLbl.heightAnchor.constraint(equalToConstant: 22),
            
            categoryLbl.leadingAnchor.constraint(equalTo: to.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            categoryLbl.trailingAnchor.constraint(equalTo: to.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            categoryLbl.topAnchor.constraint(equalTo: candyNameLbl.bottomAnchor, constant: 10),
            categoryLbl.heightAnchor.constraint(equalToConstant: 22),
            
            buyButton.leadingAnchor.constraint(equalTo: to.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buyButton.trailingAnchor.constraint(equalTo: to.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buyButton.topAnchor.constraint(equalTo: categoryLbl.bottomAnchor, constant: 10),
            buyButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    func createAmoutView(Add to: UIView) {
        
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.textColor = UIColor.white
        amountLabel.textAlignment = .center
        amountLabel.text = "數量 1"
        to.addSubview(amountLabel)
        
        amoutSetpper = UIStepper()
        amoutSetpper.value = 1
        amoutSetpper.backgroundColor = UIColor.white
        amoutSetpper.maximumValue = 99
        amoutSetpper.minimumValue = 1
        amoutSetpper.stepValue = 1;
        // By setting UIStepper property wraps to false you will make it resume from the beginning when the maximum value is reached.
        amoutSetpper.wraps = false
        // If tap and hold the button, UIStepper value will continuously increment
        amoutSetpper.autorepeat = true
        
        if #available(iOS 13.0, *) {
            let plusIcon = UIImage(systemName: "plus")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            let minusIcon = UIImage(systemName: "minus")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            amoutSetpper.setDecrementImage(minusIcon, for: .normal)
            amoutSetpper.setIncrementImage(plusIcon, for: .normal)
        }
        amoutSetpper.addTarget(self, action: #selector(didTapAmountStepperValueChanged(_:)), for: .valueChanged)
        amoutSetpper.translatesAutoresizingMaskIntoConstraints = false;
        
        to.addSubview(amoutSetpper)
        
        amoutSetpper.centerXAnchor.constraint(equalTo: to.centerXAnchor).isActive = true
        amoutSetpper.bottomAnchor.constraint(equalTo: to.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        amoutSetpper.heightAnchor.constraint(equalToConstant: 32).isActive = true
        amoutSetpper.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        amountLabel.centerXAnchor.constraint(equalTo: to.safeAreaLayoutGuide.centerXAnchor).isActive = true
        amountLabel.bottomAnchor.constraint(equalTo: amoutSetpper.topAnchor, constant: -8).isActive = true
        amountLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        amountLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }
    
    func configureView() {
        guard let item = selectItem() else {
            return
        }
        candyNameLbl.text = item.candy?.name
        categoryLbl.text = item.candy?.category.rawValue
        candyImage.image = UIImage(named: item.candy!.name)
        
        guard let width = candyImage.image?.size.width, let height = candyImage.image?.size.height else {
            return
        }
        
        let aspectRatio = width / height
        candyImage.widthAnchor.constraint(equalTo: candyImage.heightAnchor, multiplier: aspectRatio, constant: 0).isActive = true
    }
}
