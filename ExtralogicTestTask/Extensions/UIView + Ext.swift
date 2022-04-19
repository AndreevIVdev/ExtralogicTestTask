//
//  UIView + Ext.swift
//  ExtralogicTestTask
//
//  Created by Илья Андреев on 18.04.2022.
//

import UIKit

extension UIView {
    func addSubViews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}
