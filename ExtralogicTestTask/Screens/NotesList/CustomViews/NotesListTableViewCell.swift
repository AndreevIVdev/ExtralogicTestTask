//
//  NotesListTableViewCell.swift
//  ExtralogicTestTask
//
//  Created by Илья Андреев on 18.04.2022.
//

import UIKit


class NotesListTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        let selectedCellView = UIView()
        selectedCellView.backgroundColor = .orange.withAlphaComponent(0.2)
        multipleSelectionBackgroundView = selectedCellView
        selectedBackgroundView = selectedCellView
        tintColor = .orange
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
