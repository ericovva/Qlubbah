//
//  About.swift
//  QlubbahApp
//
//  Created by Эрик on 14.10.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//

import UIKit
import CoreData
class About: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    var comments_massive: NSArray = []
  
    var images: [String] = []
    var images_src: String = ""
    var id = ""
    var update = true
    var core_data_image_result: NSArray = []
    var mainImage = 0;
    var article: String = ""
    var name:String = ""
        func fetch_request() {
        let appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Photo")
        let predicate = NSPredicate(format: "id == %@", id)
        request.predicate  = predicate
        request.returnsObjectsAsFaults = false
        do{
           core_data_image_result = try context.executeFetchRequest(request)
            //print(core_data_image_result);
        }catch {
            print("error: 0: fetch error")
        }
        
        
    }
    func parse_string(){
     
            let str: String = "http://qlubbah.ru/"
            var tmp: String = ""
            let str2: String =  images_src
            for c in str2.characters {
                if (c != ",") {
                    tmp.append(c)
                    continue
                }
                print(tmp)
                if (tmp != ""){
                    images.append(str + tmp)
                    tmp = ""
                }
            }
            if (tmp != ""){
                images.append(str + tmp)
                tmp = ""
            }
            print("images[] = \(images)")
        
    }
    func add_photo(i: Int){
        let appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context)
        let imgURL: NSURL = NSURL(string: images[i])!
        if let imgData: NSData = NSData(contentsOfURL: imgURL) {
            photo.setValue(imgData,forKey: "img")
            photo.setValue(id, forKey: "id")
            photo.setValue(images[i], forKey: "source") //not used
            print("photo with id \(id) was loaded")
        }
        else {
            print("photo not loaded")
        }
        do {
            try context.save()
        } catch _ { print ("error4: Can't save object to core data")}
        print("save_photo")
        
    }
    
    func add_data(){
        
            if (id != "" && images_src != ""){
                parse_string()
                for i in 0..<images.count {
                    add_photo(i)
                    
                }
                
            }
            else {
                print("no image to show")
            }
    }
    
    
    func init_place(){
        print(update)
        print(images_src)
        print(id)
        fetch_request()
        if (core_data_image_result.count == 0 || update ) {
            add_data()
            SingletonObject.sharedInstance.about_update_ids += "," + id + ","
            print(SingletonObject.sharedInstance.about_update_ids)
            fetch_request()
        }
        print("core data_result_count\(core_data_image_result.count)")
        
    }

    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    @IBOutlet weak var edit_comment_view: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationItem.title = name
        
        navigationController?.navigationBar.tintColor = UIColor.yellowColor()
        //print(self.navigationItem.leftBarButtonItem!.title )
        init_place()
        var nib = UINib(nibName: "Presentation", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "cell")
        nib = UINib(nibName: "Article", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "cell1")
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
     
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
            selector: "keyboardWillBeShown:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        notificationCenter.addObserver(self,
            selector: "keyboardWillBeHidden:",
            name: UIKeyboardWillHideNotification,
            object: nil)
        activeTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        activeTextField.layer.borderWidth  = 1;
        activeTextField.layer.cornerRadius = 4;
        tableView.tableFooterView = edit_comment_view
        //получить отзывы
        get_comments()
      
    }
    
    
    
    var keyboard = false
    var keyboard_old_height: CGFloat = 0.0
    func keyboardWillBeShown(sender: NSNotification) {
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        UIView.animateWithDuration(0.3, animations: {
            
  
            if (self.keyboard == false){
               self.view.frame = CGRectOffset(self.view.frame, 0, -keyboardSize.height)
                self.keyboard = true
                self.keyboard_old_height = -keyboardSize.height
               
            }
            else {
                var tmp = keyboardSize.height + self.keyboard_old_height
                if tmp == 0 {
                    if keyboardSize.height <= 224 {
                        tmp = -29.0
                    }
                    else {
                        tmp = 29.0
                    }
                }
                print(tmp)
                self.view.frame = CGRectOffset(self.view.frame, 0, tmp )
                self.keyboard_old_height = -keyboardSize.height
            }
            
        })
    }
    func keyboardWillBeHidden(sender: NSNotification) {
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        //var contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        keyboard = false
            UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRectOffset(self.view.frame, 0, keyboardSize.height)
        })
        
    }
    @IBOutlet weak var activeTextField: UITextView!
    @IBAction func send_comment(sender: AnyObject) {
        let userDef = NSUserDefaults.standardUserDefaults()
        let _id = userDef.stringForKey("id")!
        let _hash = userDef.stringForKey("hash")!
        let _name = userDef.stringForKey("name")!
        let urli:NSString = "http://qlubbah.ru/api.php?keys=1&action=comment&id=\(_id)&hash=\(_hash)&mes=\(activeTextField.text)&club_id=\(id)&name=\(_name)"
        let urlStr : NSString = urli.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        if let searchURL : NSURL = NSURL(string: urlStr as String)! {
            print(searchURL)
            httpRequest(searchURL) {
                (result: NSDictionary) in
                dispatch_async(dispatch_get_main_queue()) {
                    print(result)
                    self.activeTextField.text = ""
                    self.DismissKeyboard()
                }
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue()) {
                    print("error")
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + comments_massive.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell0 = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! PresentationCell
        let cell1 = tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) as! ArticleCell
        if (indexPath.row == 0){ tableView.rowHeight = self.view.frame.size.width + 40
            
            let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
            cell0.collectionView.registerNib(nib, forCellWithReuseIdentifier: "CollectionViewCell")
            cell0.collectionView.delegate = self
            cell0.collectionView.dataSource = self
            if let imgData = core_data_image_result[mainImage].valueForKey("img"){
                cell0.img.image = UIImage(data: imgData as! NSData)
            }

        }
        else {
            tableView.estimatedRowHeight = 44.0
            tableView.rowHeight = UITableViewAutomaticDimension
            if (indexPath.row > 1){
                if let tmp  = comments_massive[indexPath.row - 2]["comment"]{
                    cell1.Article.text = tmp as? String
                }
                
            }
            else {
                cell1.Article.text = article
            }
            
            
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
            cell1.addGestureRecognizer(tap)

            return cell1
        }
        
        return cell0
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
     
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return core_data_image_result.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) ->
        UICollectionViewCell {
          
            let cell: CollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
  
                if let imgData = core_data_image_result[indexPath.row].valueForKey("img"){
                    cell.img.image = UIImage(data: imgData as! NSData)
                }
            
            
            return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("action")
        self.mainImage = indexPath.row
        self.tableView.reloadData()
    }
    
    
   
  
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func get_comments(){
        if let url = NSURL(string: "http://qlubbah.ru/api.php?keys=1&action=comment_data&club_id=\(id)") {
            httpRequest2(url) {
                (result: NSArray) in
                dispatch_async(dispatch_get_main_queue()) {
                    print(result);
                    print(result[0])
                    self.comments_massive = result
                    self.tableView.reloadData()
                    
                    }
                }
        }
        else {
            dispatch_async(dispatch_get_main_queue()) {
                //self.error_mess("Ошибка",_message:"Данные не верны")
            }
        }
        
        
    }
    
    
    func httpRequest(input: NSURL,completion: (result: NSDictionary) -> Void){
        let task = NSURLSession.sharedSession().dataTaskWithURL(input) {(data, response, error) in
            if let _data = data {
                if let result = NSString(data: _data, encoding: NSUTF8StringEncoding){
                    if let jsonData = result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true){
                        print(jsonData);
                        do {
                            let jsonDict = (try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])) as! NSDictionary
                            //println(jsonDict)
                            completion(result: jsonDict)
                        } catch {
                            print("bad data")
                        }
                        
                    }
                    else { //return nil
                        //нужно как-то обработать
                        
                    }
                }
            }
           
            
        }
        
        task.resume()
        
    }
    func httpRequest2(input: NSURL,completion: (result: NSArray) -> Void){
        let task = NSURLSession.sharedSession().dataTaskWithURL(input) {(data, response, error) in
            if let _data = data {
                if let data_error: NSData = _data {
                    if let result = NSString(data: data_error, encoding: NSUTF8StringEncoding){
                        if let jsonData = result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true){
                            do{
                                let jsonArray = try (NSJSONSerialization.JSONObjectWithData(jsonData, options: [])) as! NSArray
                                print("httpRequest: завершено")
                                completion(result: jsonArray)
                            }
                            catch _ {
                                print("error5: jsonArrayError")
                            }
                        }
                        else {
                            print("error3: error in encoding jsonData")
                        }
                    }
                }
            }
            else {
                print("error2: no data from request");
            }
            
        }
        
        task.resume()
        
    }
    


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

