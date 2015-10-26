//
//  Comments.swift
//  QlubbahApp
//
//  Created by Эрик on 25.10.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//

import UIKit

class Comments: UITableViewCell {

    @IBOutlet weak var l_name: UILabel!
    @IBOutlet weak var l_date: UILabel!
    @IBOutlet weak var r_name: UILabel!
    @IBOutlet weak var comment: UILabel!
  
    @IBOutlet weak var r_date: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
