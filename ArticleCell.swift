//
//  ArticleCell.swift
//  QlubbahApp
//
//  Created by Эрик on 16.10.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {

    @IBOutlet weak var Article: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
