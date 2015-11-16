//
//  About.swift
//  QlubbahApp
//
//  Created by Эрик on 14.10.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//

import UIKit
import CoreData
import CoreImage
class About: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    var club_number: Int!
    var search: String = ""
    var mCount: String!
    var m5: UIImageView!
    var m4: UIImageView!
    var m3: UIImageView!
    var m2: UIImageView!
    var likes: String!
    var m1: UIImageView!
    //var likeHand: UIImageView!
    //var likes: UILabel!
    var womenAge: String!
    var menAge: String!
    var women: String!
    var men: String!
    var clubName: String!
    var clubPlace: String!
   
    
    var allow_to_send = true
    var comments_massive: NSArray = []
    var update_finished = false
    var images: [String] = []
    var images_src: String = ""
    var id = ""
    var address = ""
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
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    for i in 0..<self.images.count {
                        print("add new")
                       self.add_photo(i)
                    
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.fetch_request()
                        self.update_finished = true
                        self.tableView.reloadData()
                        SingletonObject.sharedInstance.about_update_ids += "," + self.id + ","
                        print("from background thread\(SingletonObject.sharedInstance.about_update_ids)")
                    }
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
            print(update)
            print(core_data_image_result.count)
            add_data()
            print(SingletonObject.sharedInstance.about_update_ids)

        }
        else {
            update_finished = true 
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
        nib = UINib(nibName: "Comments", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "cell2")
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
        activeTextField.scrollsToTop = false
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
        if (userDef.boolForKey("auth")){
            
            if (self.allow_to_send){
                self.allow_to_send = false
                
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
                            self.allow_to_send = true
                            self.error_mess("Отзыв успешно отправлен! ", _message: "После прохождения модерации он появится на сайте.")
                        }
                    }
                }
                else {
                    allow_to_send = true
                    error_mess("Не удалось отправить отзыв.", _message: "Проверьте интернет соединение и повторите попытку.")
                    dispatch_async(dispatch_get_main_queue()) {
                        print("error")
                    }
                }
                
                
            }
        }
        else {
            error_mess("Пожалуйста авторизуйтесь.", _message: "Вы можете оставлять отзывы только после авторизации. Если у вас нет аккаунта, зарегистрируйтесь. Процедура регистрации займет не более двух минут.")
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
        let cell2 = tableView.dequeueReusableCellWithIdentifier("cell2", forIndexPath: indexPath) as! Comments
        
        
        if (indexPath.row == 0){ tableView.rowHeight = self.view.frame.size.width + 40
            
            let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
            cell0.collectionView.registerNib(nib, forCellWithReuseIdentifier: "CollectionViewCell")
            cell0.collectionView.delegate = self
            cell0.collectionView.dataSource = self
            cell0.collectionView.reloadData()
            cell0.collectionView.scrollsToTop = false
            cell0.activityIndicator.hidden = false
            cell0.activityIndicator.startAnimating()
            //////////
            cell0.clubName.text = clubName
            cell0.mCount.text = mCount
            SingletonObject.sharedInstance.old_title(cell0.womenAge, number: womenAge)
            SingletonObject.sharedInstance.old_title(cell0.menAge, number: menAge)
            //cell0.womenAge.text =  womenAge
            //cell0.menAge.text = menAge
            cell0.women.text = women + " %"
            cell0.men.text = men + " %"
            cell0.clubPlace.text = clubPlace
            cell0.search = search
            cell0.club_number = club_number
            cell0.club_id  = id
            cell0._view = self
            
            /////////
            var likees : NSArray = []
            let appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
            let context:NSManagedObjectContext = appDel.managedObjectContext
            let request = NSFetchRequest(entityName: "Place")
            let predicate = NSPredicate(format: "id == %@", id)
            request.predicate  = predicate
            request.returnsObjectsAsFaults = false
            do{
                likees = try context.executeFetchRequest(request)
                //print(core_data_image_result);
            }catch {
                print("error: 0: fetch error")
            }
            if let l = likees[0].valueForKey("likes") {
                cell0.likes.text = "\(l)"
            }
            
            //////cell0.likes.text = likes
            
            let userDef = NSUserDefaults.standardUserDefaults()
            if userDef.boolForKey("auth"){
                let was_liked = userDef.stringForKey("likes_list")
                
                if (was_liked!.rangeOfString("," + id + ",") != nil){
                    cell0.like_hand_image_in_list.image = UIImage(named: "active_like-iphone")
                }
                else {
                    cell0.like_hand_image_in_list.image = UIImage(named: "like")
                }
            }
            ////////////////
            if (update_finished){
                if let imgData = core_data_image_result[mainImage].valueForKey("img"){
                    cell0.img.image = UIImage(data: imgData as! NSData)
                    cell0.activityIndicator.hidden = true
                    cell0.activityIndicator.stopAnimating()
                }
            }
         

        }
        else {
            tableView.estimatedRowHeight = 44.0
            tableView.rowHeight = UITableViewAutomaticDimension
            if (indexPath.row > 1){
                if let tmp  = comments_massive[indexPath.row - 2]["comment"]{
                    cell2.comment.text = tmp as? String
                    if let tmp1  = comments_massive[indexPath.row - 2]["name"]{
                        cell2.l_name.text = tmp1 as? String
                        if let tmp2  = comments_massive[indexPath.row - 2]["time"]{
                           cell2.l_date.text = tmp2 as? String
                            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
                            cell2.addGestureRecognizer(tap)
                            cell2.selectionStyle = UITableViewCellSelectionStyle.None
                            return cell2
                        }
                     }
                 }
            }
            else {
                cell1.Article.text = article
                cell1.club_name.text = name
                cell1.club_address.text  = address
                let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
                cell1.addGestureRecognizer(tap)
                cell1.selectionStyle = UITableViewCellSelectionStyle.None
                return cell1
            }
            
            
            
        }
        cell0.selectionStyle = UITableViewCellSelectionStyle.None
        return cell0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor(
            red: CGFloat( 255 / 255.0),
            green: CGFloat(255 / 255.0),
            blue: CGFloat( 255 / 255.0),
            alpha: CGFloat(1.0)
        )

    }
    
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
     
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return core_data_image_result.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) ->
        UICollectionViewCell {
            print(core_data_image_result.count)
            let cell: CollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
  
                if let imgData = core_data_image_result[indexPath.row].valueForKey("img"){
                    
                    
                    
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//                        let originalImage: UIImage  =  UIImage(data: imgData as! NSData)!
//                        let ciContext = CIContext(options: nil)
//                        let startImage = CIImage(image: originalImage)
//                        let filter = CIFilter(name: "CIMaximumComponent")
//                        filter!.setDefaults()
//                        filter!.setValue(startImage, forKey: kCIInputImageKey)
//                        let filteredImageData = filter!.valueForKey(kCIOutputImageKey) as! CIImage
//                        let filteredImageRef = ciContext.createCGImage(filteredImageData, fromRect: filteredImageData.extent)
//                        
//                      
//                        dispatch_async(dispatch_get_main_queue()) {
//                            cell.img.image = UIImage(CGImage: filteredImageRef);
//                        }
//                    }
                    if mainImage == indexPath.row {
                        cell.view.hidden = true
                        cell.img.layer.borderColor = UIColor.yellowColor().CGColor
                        cell.img.layer.borderWidth = 2
                    }
                    else {
                         cell.view.hidden = false
                        cell.img.layer.borderWidth = 0
                    }
                    cell.img.image = UIImage(data: imgData as! NSData)
                    
                }
            
            
            return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("action")
        self.mainImage = indexPath.row
        
        self.tableView.reloadData()
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
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
    func error_mess(_title: String,_message: String){
        let alert = UIAlertController(title: _title, message: _message, preferredStyle: UIAlertControllerStyle.Alert)
        //alert.view.backgroundColor = UIColor.darkGrayColor()
        alert.addAction(UIAlertAction(title: "Закрыть", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

}

