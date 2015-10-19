//
//  CustomSubView.swift
//  QlubbahApp
//
//  Created by Эрик on 08.10.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//

import UIKit

class CustomSubView: UIView {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var likes: UILabel!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    @IBAction func like_button(sender: AnyObject) {
        print("CLICKED")
    }

}
