//
//  CandyDetailViewModel.swift
//  CandyWithMVVMC
//
//  Created by William on 2018/12/26.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

protocol CandyDetailViewControllerDelegate: class {
  //func candyDetailViewController(_ candyDetailViewController: CandyDetailViewController, didBuy candy: Candy)
    
    func candyDetailViewController(didBuy candy: inout Candy, amount: Double)
}

class CandyDetailViewModel {
    
    weak var delegate: CandyDetailViewControllerDelegate?
    
    weak var viewDelegate: CandyDetailViewModelViewDelegate?
    
    var candy: Candy?
    
    var candyDataType: CandyDetailViewDataType?
    
    var amountLabel: UILabel = UILabel()
    var amoutSetpper: UIStepper!
    
    func start() {
        viewDelegate?.updateScreen()
    }
}

extension CandyDetailViewModel: CandyDetailViewModelType {
    func selectCandy() -> Candy? {
        return self.candyDataType?.getCandy()
    }
    
    func setUpByButton(buyButton: UIButton, isBuy: Bool) {
        buyButton.setTitle("Buy", for: .normal)
        buyButton.isHidden = isBuy
    }
}

extension CandyDetailViewModel {
    
    func didTapBuyButton() {
      
        guard var candy = selectCandy() else {
            return
        }
        
        delegate?.candyDetailViewController(didBuy: &candy, amount: amoutSetpper.value)
        //navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func didTapAmountStepperValueChanged(_ sender: UIStepper) {
        amountLabel.text = "數量 \(Int(sender.value).description)"
    }
    
    func createAmoutView(Add to: UIView) {
        
        amountLabel.translatesAutoresizingMaskIntoConstraints = false;
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
        
        let plusIcon = UIImage(systemName: "plus")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        let minusIcon = UIImage(systemName: "minus")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        
        amoutSetpper.setDecrementImage(minusIcon, for: .normal)
        amoutSetpper.setIncrementImage(plusIcon, for: .normal)
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
}
