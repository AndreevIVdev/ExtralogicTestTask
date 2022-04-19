//
//  Date + Ext.swift
//  ExtralogicTestTask
//
//  Created by Илья Андреев on 18.04.2022.
//

import Foundation

extension Date {
    func inShortFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = Calendar.current.isDateInToday(self) ? "h:mm a" : "dd/MM/yy"
        return formatter.string(from: self)
    }
}
