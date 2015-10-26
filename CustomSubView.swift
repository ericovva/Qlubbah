//
//  CustomSubView.swift
//  QlubbahApp
//
//  Created by Эрик on 08.10.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//

import UIKit

class CustomSubView: UIView {

    @IBOutlet weak var bg: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
   
    @IBOutlet weak var m_a: UILabel!
    @IBOutlet weak var w_a: UILabel!
    @IBOutlet weak var c: UILabel!
    @IBOutlet weak var m_c: UILabel!
    @IBOutlet weak var w_c: UILabel!
  
 
    
    
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        bg.layer.cornerRadius = 10
        bg.clipsToBounds = true
        // Drawing code
    }
    

}
