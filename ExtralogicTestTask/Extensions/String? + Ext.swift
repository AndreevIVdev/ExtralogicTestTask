//
//  String? + Ext.swift
//  ExtralogicTestTask
//
//  Created by Илья Андреев on 19.04.2022.
//

import Foundation

extension Optional where Wrapped == String {
    var orEmpty: String {
        switch self {
        case .none:
            return ""
        case .some(let value):
            return value
        }
    }
}
