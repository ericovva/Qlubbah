//
//  completeReg.swift
//  QlubbahApp
//
//  Created by Эрик on 12.10.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//

import UIKit

class completeReg: UIViewController {
    var id_reg:Int!
    var go_out = false
    @IBOutlet weak var fu_button: UIBarButtonItem!
    func error_mess(_title: String,_message: String){
        let alert = UIAlertController(title: _title, message: _message, preferredStyle: UIAlertControllerStyle.Alert)
        //alert.view.backgroundColor = UIColor.darkGrayColor()
        let okButton = UIAlertAction(title: "Закрыть", style: UIAlertActionStyle.Default) { (okSelected) -> Void in
            if (self.go_out) {
                self.popVC()
            }
        }
        alert.addAction(okButton)
        //alert.addAction(UIAlertAction(title: "Закрыть", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
        
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
    
    
    
    

    @IBAction func completeReg(sender: AnyObject) {
        //ниже переход
        send_request()
   
  

    }
    @IBOutlet weak var complete: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.tintColor = UIColor.yellowColor()
        fu_button.tintColor = UIColor.clearColor()
        fu_button.enabled = false
        print(id_reg)
        activate_field.becomeFirstResponder()
        self.activate_field.keyboardType = UIKeyboardType.PhonePad
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBOutlet weak var activate_field: UITextField!
    func send_request() {
        
        if(activate_field.text! != ""){
            let st = activate_field.text! + "&id_reg=" + String(id_reg);
            let url_srt: NSString = "http://qlubbah.ru/api.php?action=active_check&keys=1&code=\(st)";
            let urlStr : NSString = url_srt.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            if let searchURL : NSURL = NSURL(string: urlStr as String)! {
                httpRequest(searchURL) {
                    (result: NSDictionary) in
                    dispatch_async(dispatch_get_main_queue()) {
                        if let _result:NSDictionary = result{
                            if nil != _result["id"] && nil != _result["name"] && nil != _result["hash"] && nil != _result["phone"] && nil != _result["email"] && nil != _result["present_code"] {
                                print(_result)
                                self.save_data(_result["name"]! as! String,
                                                token: _result["hash"]! as! String,
                                                id: _result["id"]! as! String,
                                                likes_list: "",
                                                email: _result["email"]! as! String,
                                                phone: _result["phone"]! as! String,
                                                promo: _result["present_code"]! as! String)
                                if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("pr") as? Profile{
                                    let navController = UINavigationController(rootViewController: secondViewController)
                                    navController.setViewControllers([secondViewController], animated:true)
                                    self.revealViewController().setFrontViewController(navController, animated: true) //если свой поставишь, поменяй на false
                                    
                                }
                            } else {
                                if _result["try"] != nil {
                                    let tmp = _result["try"]!;
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.error_mess("Ошибка",_message:"Вы не правильно ввели код активации.У вас осталось попыток:\(tmp)")
                                    }
                                } else {
                                    if _result["try_finished"] != nil {
                                        if(_result["try_finished"]! as! Int == 1){
                                            dispatch_async(dispatch_get_main_queue()) {
                                                self.error_mess("Ошибка",_message:"У вас кончились попытки")
                                            }
                                        }
                                        self.go_out = true
                                        //self.dismissViewControllerAnimated(true, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func popVC(){
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
