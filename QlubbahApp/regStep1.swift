//
//  regStep1.swift
//  Qlubbah
//
//  Created by Эрик on 19.09.15.
//  Copyright (c) 2015 qlubbah. All rights reserved.
//

import UIKit

class regStep1: UIViewController {

    @IBAction func next(sender: AnyObject) {
        // выполнить переход
        performSegueWithIdentifier("step2", sender: nil)
    }
   
    @IBOutlet weak var menuButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.navigationController?.navigationBar.translucent = false
       
        self.reg_email.keyboardType = UIKeyboardType.EmailAddress
        self.reg_phone.keyboardType = UIKeyboardType.PhonePad
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        reg_name.becomeFirstResponder()

        

        
    }
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let range = testStr.rangeOfString(emailRegEx, options:.RegularExpressionSearch)
        let result = range != nil ? true : false
        return result
    }
    @IBOutlet weak var reg_name: UITextField!
    @IBOutlet weak var reg_email: UITextField!
    @IBOutlet weak var reg_phone: UITextField!
    
    func httpRequest(input: NSURL,completion: (result: NSDictionary) -> Void){
        let task = NSURLSession.sharedSession().dataTaskWithURL(input) {(data, response, error) in
            if let _data = data {
                if let data_error: NSData = _data {
                    if let result = NSString(data: data_error, encoding: NSUTF8StringEncoding){
                        if let jsonData = result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true){
                            let jsonDict = (try! NSJSONSerialization.JSONObjectWithData(jsonData, options: [])) as! NSDictionary
                            completion(result: jsonDict)                        }
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "step2" {
            let svc = segue.destinationViewController as! regStep2;
            
            svc.name = reg_name.text
            svc.email = reg_email.text
            svc.phone = reg_phone.text
        }
    }
    @IBAction func send_but(sender: UIBarButtonItem) {
        if(reg_email.text != "" && reg_name.text != "" && reg_phone.text != ""){
            if reg_phone.text!.characters.count == 10 {
                if(isValidEmail(reg_email.text!)){
                    
                    let st1 = (reg_phone.text! + "&email=" + reg_email.text!)
                    let st2 = "&name=" + reg_name.text! ;
                    let url_srt: NSString = "http://qlubbah.ru/api.php?action=phone_email_check&keys=1&phone=\(st1 + st2)"
                    let urlStr : NSString = url_srt.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                    if let searchURL : NSURL = NSURL(string: urlStr as String)! {
                        httpRequest(searchURL) {
                            (result: NSDictionary) in
                            dispatch_async(dispatch_get_main_queue()) {
                                if let _result:NSDictionary = result{
                                    if let ans =  _result["error"] {
                                        dispatch_async(dispatch_get_main_queue()) {
                                            self.error_mess("Ошибка",_message:ans as! String)
                                        }
                                    }else{
                                        print(_result)
                                        self.performSegueWithIdentifier("step2", sender: nil)
                                    }
                                } else {
                                    print("warning1: result is nil")
                                }
                            }
                        }
                    }
                    else {
                        print("dsadas")
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.error_mess("Ошибка",_message:"Вы не правильно ввели E-mail")
                    }
                }
            }else{
                dispatch_async(dispatch_get_main_queue()) {
                    self.error_mess("Ошибка",_message:"Вы не правильно ввели мобильный телефон")
                }
            }
        }else{
            dispatch_async(dispatch_get_main_queue()) {
                self.error_mess("Ошибка",_message:"Вы оставили пустое поле")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    
}
