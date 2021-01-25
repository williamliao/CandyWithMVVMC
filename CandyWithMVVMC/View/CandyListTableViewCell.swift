//
//  CandyListTableViewCell.swift
//  CandyWithMVVMC
//
//  Created by 雲端開發部-廖彥勛 on 2021/1/20.
//  Copyright © 2021 雲端開發部-廖彥勛. All rights reserved.
//

import UIKit

class CandyListTableViewCell: UITableViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: CandyListTableViewCell.self)
    }
    
    var titleLabel: UILabel!
    var subTitleLabel: UILabel!
    var iconImageView: UIImageView!
    var discountImageView: UIImageView!
    var amountLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
        configureConstraints()
    }
    
    func configureView() {
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        
        subTitleLabel = UILabel()
        subTitleLabel.font = UIFont.systemFont(ofSize: 14)
        
        amountLabel = UILabel()
        amountLabel.font = UIFont.systemFont(ofSize: 14)
        amountLabel.isHidden = true
        
        iconImageView = UIImageView()
        
        discountImageView = UIImageView()
        discountImageView.isHidden = true
        discountImageView.image = UIImage(named: "discount")
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(iconImageView)
        contentView.addSubview(discountImageView)
        contentView.addSubview(amountLabel)
    }
    
    func configureConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        discountImageView.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 44),
            iconImageView.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: discountImageView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.heightAnchor.constraint(equalToConstant: 16),
            
            subTitleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            subTitleLabel.trailingAnchor.constraint(equalTo: discountImageView.leadingAnchor),
            subTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            
            discountImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            discountImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            discountImageView.widthAnchor.constraint(equalToConstant: 44),
            discountImageView.heightAnchor.constraint(equalToConstant: 44),
            
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            amountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            amountLabel.widthAnchor.constraint(equalToConstant: 44),
            amountLabel.heightAnchor.constraint(equalToConstant: 16),
        ])
    }
    
    func showShowDiscount(show: Bool) {
        discountImageView.isHidden = !show
    }
    
    func showAmount(show: Bool, amount: Double) {
        amountLabel.isHidden = !show
        amountLabel.text = "\(Int(amount))"
    }
}

extension CandyListTableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        amountLabel.isHidden = true
        discountImageView.isHidden = true
    }
}
