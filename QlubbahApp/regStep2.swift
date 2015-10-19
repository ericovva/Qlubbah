//
//  regStep2.swift
//  Qlubbah
//
//  Created by Эрик on 19.09.15.
//  Copyright (c) 2015 qlubbah. All rights reserved.
//

import UIKit

class regStep2: UIViewController {
    var name:String!
    var phone:String!
    var email:String!
    
    @IBAction func next(sender: AnyObject) {
        performSegueWithIdentifier("step3", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.tintColor = UIColor.yellowColor()
        self.navigationController?.navigationBar.translucent = false
        
      
        
    }
    
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
    @IBOutlet weak var reg_pass: UITextField!
    @IBOutlet weak var reg_pass1: UITextField!
    @IBOutlet weak var reg_prom: UITextField!
    
    
    @IBAction func next_2but(sender: UIBarButtonItem) {
        if(reg_pass.text! != "" && reg_pass1.text! != ""){
            if(reg_pass.text! == reg_pass1.text!){
                var url_srt = "http://qlubbah.ru/api.php?action=reg&keys=1&phone="
                url_srt += phone + "&name="
                url_srt += name + "&email="
                url_srt += email + "&pass="
                url_srt += reg_pass.text! + "&pass1="
                url_srt += reg_pass1.text!
                print(url_srt);
                if let url = NSURL(string: url_srt) {
                    httpRequest(url) {
                        (result: NSDictionary) in
                        dispatch_async(dispatch_get_main_queue()) {
                            if let _result:NSDictionary = result{
                                if let ans =  _result["error"] {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.error_mess("Ошибка",_message:ans as! String)
                                    }
                                }else{
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.error_mess("Ошибка",_message:_result["id_reg"] as! String)
                                    }
                                }
                            } else {
                                print("warning1: result is nil")
                            }
                        }
                    }
                }
                
            }else{
                dispatch_async(dispatch_get_main_queue()) {
                    self.error_mess("Ошибка",_message:"Паролли не совпадают")
                }
            }
        }else{
            dispatch_async(dispatch_get_main_queue()) {
                self.error_mess("Ошибка",_message:"Паролли не введены")
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    
}
