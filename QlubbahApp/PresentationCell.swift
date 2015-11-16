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
    var club_id: String!
    var club_number: Int!
    var search: String!
    var _view: UIViewController!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var like_hand_image_in_list: UIImageView!
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
    @IBAction func like_button(sender: AnyObject) {
        let userDef = NSUserDefaults.standardUserDefaults()
        if (Reachability.isConnectedToNetwork()){
            if (userDef.boolForKey("auth")){
                print(search)
                print(club_number)
                SingletonObject.sharedInstance.like_club(likes, img: likeHand, club_id: club_id)
                
            }
            else {
                self.error_mess("Авторизуйтесь", _message: "Для этого действия необходима авторизация.")
            }
        }
        else {
            self.error_mess("Ошибка соединения", _message: "Прверьте подключение к Интернету.")
            
        }
        
    }
    func error_mess(_title: String,_message: String){
        let alert = UIAlertController(title: _title, message: _message, preferredStyle: UIAlertControllerStyle.Alert)
        //alert.view.backgroundColor = UIColor.darkGrayColor()
        alert.addAction(UIAlertAction(title: "Закрыть", style: UIAlertActionStyle.Default, handler: nil))
        _view.presentViewController(alert, animated: true, completion: nil)
    }

 
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awake")
     
     
        
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
