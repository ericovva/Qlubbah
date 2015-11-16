//
//  Profile.swift
//  Qlubbah
//
//  Created by Эрик on 22.09.15.
//  Copyright (c) 2015 qlubbah. All rights reserved.
//

import UIKit
import Haneke
class Profile: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var bg: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var promo: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
  
  
    
   
    @IBOutlet weak var pView: UIView!
    @IBOutlet weak var changePass: UIButton!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var exitProfile: UIButton!
    
    @IBAction func exitFromProfile(sender: AnyObject) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(false, forKey: "auth")
        if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("au") as? Auth {
            let navController = UINavigationController(rootViewController: secondViewController)
            self.revealViewController().setFrontViewController(navController, animated: true)
            navController.setViewControllers([secondViewController], animated:true)
            
        }
    }
    
    
    override func viewDidLoad() {
        //performSegueWithIdentifier("sw_right", sender: nil)
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
         //self.view.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(0.1){
                //self.view.transform = CGAffineTransformMakeScale(1, 1)
        }
        exitProfile.layer.borderColor = UIColor.darkGrayColor().CGColor
        exitProfile.layer.borderWidth = 2
        changePass.layer.borderColor = UIColor.darkGrayColor().CGColor
        changePass.layer.borderWidth = 2
        navigationController?.navigationBar.tintColor = UIColor.yellowColor()
        
        let userDef = NSUserDefaults.standardUserDefaults()
        if ( userDef.boolForKey("auth")){
            self.name.text = userDef.stringForKey("name")
            self.email.text = userDef.stringForKey("email")
            self.promo.text = userDef.stringForKey("promo")
            self.phone.text = userDef.stringForKey("phone")
        }
        else {
            print("wtf???!!!")
        }
        myImageView.layer.cornerRadius = myImageView.frame.width / 2
        myImageView.clipsToBounds = true
        //get_inf()
        var loaded_img = UIImage!()
        
            let st = userDef.stringForKey("user_image")
            if let st_ = st {
                    let cache = Shared.dataCache
                    cache.fetch(key: st_).onSuccess { data in
                        loaded_img  = UIImage(data: data)

                        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        self.photo.image = loaded_img
                        self.bg.image = loaded_img
                }
            }
        
        
        get_inf()


     
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
                self.bg.image = UIImage(data:data)
                let cache = Shared.dataCache
                
                cache.set(value: data, key: key)
                let ud = NSUserDefaults.standardUserDefaults()
                ud.setObject(key, forKey: "user_image")
            }
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        
        //performSegueWithIdentifier("sw_right", sender: nil)
    }
    

  
    
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
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
                        print(self.revealViewController())
                        self.exitFromProfile(0)
                        

                        
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
    

    
    
    /// change image
    @IBOutlet weak var save_button: UIButton!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var myImageView: UIImageView!
    
    @IBAction func change_photo(sender: AnyObject) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(myPickerController, animated: true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        save_button.hidden = false
        myImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save_photo(sender: AnyObject) {
        myImageUploadRequest()
        save_button.hidden = true
    }
    func myImageUploadRequest()
    {
        
        let myUrl = NSURL(string: "http://qlubbah.ru/api.php");
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST";
        let userDef = NSUserDefaults.standardUserDefaults()
        print(userDef.stringForKey("id")!)
        let param = [
            "id"  : userDef.stringForKey("id")!,
            "hash"    : userDef.stringForKey("hash")!,
            "keys" : "1",
            "action" : "add_profile_photo"
            
            
        ]
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        let imageData = UIImageJPEGRepresentation(myImageView.image!, 0.1)
        
        if(imageData==nil)  { return; }
        
        request.HTTPBody = createBodyWithParameters(param, filePathKey: "profile_photo", imageDataKey: imageData!, boundary: boundary)
        
        
        
        myActivityIndicator.startAnimating();
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            // You can print out response object
            print("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("****** response data = \(responseString!)")
            print("DATA\(data!)")
            var error = false
            do {
                 let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                print(json)
                if (json!["unsset"] != nil) {
                    error = true
                }
                if let st_ = json!["ok"] {
                    userDef.setObject("http://qlubbah.ru/" + (st_ as! String), forKey: "user_image")
                    
                }
            }
            catch _ {
                print("no result");
            }
           
            
         
            
            
            dispatch_async(dispatch_get_main_queue(),{
                self.myActivityIndicator.stopAnimating()
                //self.myImageView.image = nil;
                if error {
                    self.exitFromProfile(0)
                }
            });
            
        }
        
        task.resume()
        
    }
    
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "user-profile.jpg"
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    
    
    
}



extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}






