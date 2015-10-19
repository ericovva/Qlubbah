//
//  Auth.swift
//  Qlubbah
//
//  Created by Эрик on 17.09.15.
//  Copyright (c) 2015 qlubbah. All rights reserved.
//

import UIKit
import CoreData
class Auth: UIViewController {
    
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var reg: UIButton!
    @IBOutlet weak var bg: UIImageView!

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBAction func menuTap(sender: AnyObject) {
        DismissKeyboard()
    }
    @IBAction func go_to_reg(sender: AnyObject) {
        if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("reg") as? regStep1{
            let navController = UINavigationController(rootViewController: secondViewController)
            navController.setViewControllers([secondViewController], animated:true)
            self.revealViewController().setFrontViewController(navController, animated: true) //если свой поставишь, поменяй на false
            
            
        }

    }
    @IBAction func auth_check(sender: AnyObject) {
        DismissKeyboard()
        var success = false
        if let url = NSURL(string: "http://qlubbah.ru/api.php?keys=1&action=auth&login=\(email.text!)&pass=\(password.text!)") {
            httpRequest(url) {
                (result: NSDictionary) in
                dispatch_async(dispatch_get_main_queue()) {
                    //print("RESULT: \(result)")
                    success = self.check(result)
                    if (success){
                        //self.performSegueWithIdentifier("sw_right", sender: nil)
                        UIView.animateWithDuration(0.1,
                            animations: {
                                //self.view.transform = CGAffineTransformMakeScale(0.1, 0.1)
                            },
                            completion: { finished in
                                if finished{
                                    if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("pr") as? Profile {
                                        let navController = UINavigationController(rootViewController: secondViewController)
                                        navController.setViewControllers([secondViewController], animated:true)
                                        self.revealViewController().setFrontViewController(navController, animated: true) //если свой поставишь, поменяй на false
                                        
                                    
                                    }
                                    
                                }
                                
                                
                        });
                        
                        
                       
                        
                    }
                    else {
                        //performSegue
                        self.error_mess("Ошибка",_message:"Данные не верны")
                    }
                }
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue()) {
                //self.error_mess("Ошибка",_message:"Данные не верны")
            }
        }
        
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        initial()
    }
    
    func httpRequest(input: NSURL,completion: (result: NSDictionary) -> Void){
        let task = NSURLSession.sharedSession().dataTaskWithURL(input) {(data, response, error) in
            
            if let result = NSString(data: data!, encoding: NSUTF8StringEncoding){
                if let jsonData = result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true){
                    //println(jsonData);
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
        
        task.resume()
        
    }
    func check(jsonDict: NSDictionary) -> Bool{
        var name = "",
        id = "",
        token = "",
        likes_list = "",
        email = "",
        phone = "",
        promo = ""
        print(jsonDict);

        if let _name: AnyObject = jsonDict["name"]{
            name = _name as! String ; print(name)
            if let _token: AnyObject = jsonDict["hash"]{
                token = _token as! String ; print(token)
                if let _id: AnyObject = jsonDict["id"]{
                    id = _id as! String ; print(id)
                    if let _likes_list: AnyObject = jsonDict["likes_list"]{
                        likes_list = _likes_list as! String ; print(likes_list)
                        if let _email: AnyObject = jsonDict["email"]{
                            email = _email as! String ; print(email)
                            if let _phone: AnyObject = jsonDict["phone"]{
                                phone = _phone as! String ; print(phone)
                                if let _promo: AnyObject = jsonDict["present_code"]{
                                    promo = _promo as! String ; print(promo)
                                    save_data(name,token: token,id: id, likes_list: likes_list, email: email, phone: phone, promo: promo)
                                }
                            }
                        }
                        
                        //error_message_var = true
                        //println(error_message_var)
                        return true
                    }
                }
            }
        }
        print("return false")
        return false

    }
    
    func save_data(name: String,token: String, id: String,likes_list: String,email: String, phone: String, promo: String){
        //userdefault
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(true, forKey: "qlubbah_man")
        userDefaults.setBool(true, forKey: "auth")
        userDefaults.setObject(id, forKey: "id")
        userDefaults.setObject(token, forKey: "hash")
        userDefaults.setObject(likes_list, forKey: "likes_list")
        userDefaults.setObject(name, forKey: "name")
        userDefaults.setObject(email, forKey: "email")
        userDefaults.setObject(phone, forKey: "phone")
        userDefaults.setObject(promo, forKey: "promo")
       
    }
    func error_mess(_title: String,_message: String){
        let alert = UIAlertController(title: _title, message: _message, preferredStyle: UIAlertControllerStyle.Alert)
        //alert.view.backgroundColor = UIColor.darkGrayColor()
        alert.addAction(UIAlertAction(title: "Закрыть", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    func initial(){
      
        reg.layer.borderColor = UIColor.darkGrayColor().CGColor
        reg.layer.borderWidth = 2
        self.password.secureTextEntry = true
        self.email.keyboardType = UIKeyboardType.EmailAddress
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        let dtap: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(dtap)
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "DismissKeyboard")
        self.bg.addGestureRecognizer(pan)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
   
   
 

}
