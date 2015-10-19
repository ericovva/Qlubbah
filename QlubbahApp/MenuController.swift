//
//  MenuController.swift
//  SidebarMenu
//
//  Created by Simon Ng on 2/2/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit

class MenuController: UITableViewController {

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
        if ( userDef.boolForKey("auth")){
            enter_or_frofile.text = userDef.stringForKey("name")! + "\n" + "Личный кабинет"
            
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

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
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
