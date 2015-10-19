//
//  PresentationCell.swift
//  QlubbahApp
//
//  Created by Эрик on 15.10.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//

import UIKit

class PresentationCell: UITableViewCell , UICollectionViewDelegate, UICollectionViewDataSource{
    @IBOutlet weak var img: UIImageView!

    @IBOutlet weak var collectionView: UICollectionView!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("awake")
        //collectionView.dataSource = self
        //collectionView.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
     
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    

  
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        print("DDD")
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("DDD")
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) ->
        UICollectionViewCell {
            print("DDD")
        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath)
        if indexPath.row%2 == 0 {
            cell.backgroundColor = UIColor.redColor()
        } else {
            cell.backgroundColor = UIColor.yellowColor()
        }
        return cell
    }
    

}
