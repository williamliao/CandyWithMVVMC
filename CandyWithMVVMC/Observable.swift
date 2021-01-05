//
//  Observable.swift
//  CandyWithMVVMC
//
//  Created by 雲端開發部-廖彥勛 on 2020/12/25.
//  Copyright © 2020 雲端開發部-廖彥勛. All rights reserved.
//

import UIKit

class Observable<T> {

    var value: T {
        didSet {
            DispatchQueue.main.async {
                self.listener?(self.value)
            }
        }
    }

    private var listener: ((T) -> Void)?

    init(_ value: T) {
        self.value = value
    }

    func bind(_ closure: @escaping (T) -> Void) {
        closure(value)
        listener = closure
    }
}
