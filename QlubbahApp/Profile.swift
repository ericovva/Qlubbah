//
//  Profile.swift
//  Qlubbah
//
//  Created by Эрик on 22.09.15.
//  Copyright (c) 2015 qlubbah. All rights reserved.
//

import UIKit

class Profile: UIViewController {
    
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
            navController.setViewControllers([secondViewController], animated:true)
            self.revealViewController().setFrontViewController(navController, animated: true)
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

        
        
        
        
        //get_inf()


     
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
    
    func httpRequest(input: NSURL,completion: (result: NSDictionary) -> Void){
        let task = NSURLSession.sharedSession().dataTaskWithURL(input) {(data, response, error) in
            if let _data = data {
            if let data_error: NSData = _data {
                if let result = NSString(data: data_error, encoding: NSUTF8StringEncoding){
                    if let jsonData = result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true){
                        print(jsonData);
                        do{
                        let jsonDict = (try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])) as! NSDictionary
                            completion(result: jsonDict)
                    
                        }
                        catch {
                            print ("Data \(jsonData) is incorrect")
                        }
                        
                    }

                    else { //return nil
                        //нужно как-то обработать
                        
                    }
                }
            }
            }
        
            else {
                print("DATA ERROR");
            }
            
        }
        
        task.resume()
        
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
        print("http://qlubbah.ru/api.php?keys=1&action=profile&id=\(id)&hash=\(hash)")
        //if (!userDefaults.boolForKey("qlubbah_man"))
        if let url = NSURL(string: "http://qlubbah.ru/api.php?keys=1&action=profile_data&id=\(id)&hash=\(hash)") {
            httpRequest(url) {
                (result: NSDictionary) in
                dispatch_async(dispatch_get_main_queue()) {
                    //print("RESULT: \(result)")
                    //success = self.check(result)
                    
                
                    if let result_ = result["data"]{
                        print(result_)
                        
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

    


}
