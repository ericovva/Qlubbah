//
//  ClubTableViewCell.swift
//  SidebarMenu
//
//  Created by Эрик on 29.09.15.
//  Copyright © 2015 AppCoda. All rights reserved.
//

import UIKit

class ClubTableViewCell: UITableViewCell {

    
    @IBOutlet weak var mCount: UILabel!
    @IBOutlet weak var m5: UIImageView!
    @IBOutlet weak var m4: UIImageView!
    @IBOutlet weak var m3: UIImageView!
    @IBOutlet weak var m2: UIImageView!
    @IBOutlet weak var m1: UIImageView!
    @IBOutlet weak var likeHand: UIImageView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var womenAge: UILabel!
    @IBOutlet weak var menAge: UILabel!
    @IBOutlet weak var women: UILabel!
    @IBOutlet weak var men: UILabel!
    @IBOutlet weak var clubPlace: UILabel!
    @IBOutlet weak var clubName: UILabel!
    @IBOutlet weak var photo: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func like_button(sender: AnyObject) {
        print("CLICK")
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
