//
//  MenuController.swift
//  SidebarMenu
//
//  Created by Simon Ng on 2/2/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit
import Haneke
class MenuController: UITableViewController {

    @IBOutlet weak var cell: UIView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var enter_or_frofile: UILabel!
    @IBOutlet var TV: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        TV.tableFooterView = UIView();
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let userDef = NSUserDefaults.standardUserDefaults()
        cell.backgroundColor = UIColor(
            red: CGFloat( 255 / 255.0),
            green: CGFloat(242 / 255.0),
            blue: CGFloat( 0 / 255.0),
            alpha: CGFloat(1.0)
        )
        photo.layer.cornerRadius = photo.frame.width / 2
        photo.clipsToBounds = true
        
        if ( userDef.boolForKey("auth")){
            enter_or_frofile.text = userDef.stringForKey("name")! + "\n" + "Личный кабинет"
            var loaded_img = UIImage!()
            let st = userDef.stringForKey("user_image")
            if let st_ = st {
                let cache = Shared.dataCache
                cache.fetch(key: st_).onSuccess { data in
                    loaded_img  = UIImage(data: data)
                    
                    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    self.photo.image = loaded_img
                }
            }
            
            
            get_inf()
            
        }
        else {
            enter_or_frofile.text = "Войти"
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("set")
        let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor(
            red: CGFloat( 255 / 255.0),
            green: CGFloat(179 / 255.0),
            blue: CGFloat( 15 / 255.0),
            alpha: CGFloat(1.0)
        )
        switch(indexPath.row){
        case 0:
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            if (!userDefaults.boolForKey("auth"))
            {
            
                performSegueWithIdentifier("auth", sender: nil)
                
            }
            else {
                performSegueWithIdentifier("profile", sender: nil)
            }
        case 1: SingletonObject.sharedInstance.view = 0
        case 2: SingletonObject.sharedInstance.view = 1
            
        default: print("sds")
        }
    }
    
    override func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell  = tableView.cellForRowAtIndexPath(indexPath)
        cell!.contentView.backgroundColor = UIColor(
            red: CGFloat( 255 / 255.0),
            green: CGFloat(179 / 255.0),
            blue: CGFloat( 15 / 255.0),
            alpha: CGFloat(1.0)
        )
    }
    
    override func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell  = tableView.cellForRowAtIndexPath(indexPath)
        cell!.contentView.backgroundColor = .clearColor()
    }
    
    
    

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    func downloadImage(url: NSURL,key: String){
        print("Started downloading \"\(url.URLByDeletingPathExtension!.lastPathComponent!)\".")
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                print("Finished downloading \"\(url.URLByDeletingPathExtension!.lastPathComponent!)\".")
                self.photo.image = UIImage(data: data)
                let cache = Shared.dataCache
                
                cache.set(value: data, key: key)
                let ud = NSUserDefaults.standardUserDefaults()
                ud.setObject(key, forKey: "user_image")
            }
        }
    }
    
    
    func get_inf(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var id: String = "";
        var hash: String = "";
        if let _id = userDefaults.stringForKey("id"){
            id = _id
        }
        if let _hash = userDefaults.stringForKey("hash"){
            hash = _hash
        }
        print("http://qlubbah.ru/api.php?keys=1&action=profile_data_photo&id=\(id)&hash=\(hash)")
        if let url = NSURL(string: "http://qlubbah.ru/api.php?keys=1&action=profile_data_photo&id=\(id)&hash=\(hash)") {
            SingletonObject.sharedInstance.httpRequest(url) {
                (result: NSDictionary) in
                dispatch_async(dispatch_get_main_queue()) {
                    if result["unsset"] != nil {
                        
                    }
                    
                    if let result_ = result["avatar"]{
                        print(result_)
                        let st_ = "http://qlubbah.ru/" + (result_ as! String)
                        let cache = Shared.dataCache
                        if let checkedUrl = NSURL(string: st_ as String) {
                            cache.fetch(key: st_).onFailure({ _ in  print("FAIL")})
                            self.downloadImage(checkedUrl,key: st_)
                        }
                    }
                    else {
                        print("NO RESULT")
                    }
                }
            }
        }
        else {
            print("Invalid request")
            
        }
        
    }

    


    
    // MARK: - Table view data source


    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
