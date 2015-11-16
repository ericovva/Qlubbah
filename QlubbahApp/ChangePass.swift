//
//  ChangePass.swift
//  QlubbahApp
//
//  Created by Эрик on 26.10.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//

import UIKit

class ChangePass: UIViewController {
    var go_out = false
    @IBOutlet weak var old_pass: UITextField!
    @IBOutlet weak var new_pass: UITextField!
    @IBOutlet weak var repeat_pass: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        old_pass.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ready(sender: AnyObject) {
        let userDef = NSUserDefaults.standardUserDefaults()
        
        if (Reachability.isConnectedToNetwork()){
            if ((userDef.boolForKey("auth"))){
                if (repeat_pass.text != "" && new_pass.text != "" && old_pass.text != ""){
                    if (new_pass.text == repeat_pass.text){
                        //отправляем запрос
                        var st = "&new_pass=" + new_pass.text!
                            st += "&new_pass1=" + repeat_pass.text!
                            st += "&old_pass=" + old_pass.text!
                            st += "&id=" + userDef.stringForKey("id")!
                            st += "&hash=" + userDef.stringForKey("hash")!
                        let url_srt: NSString = "http://qlubbah.ru/api.php?action=profile_pass_cng&keys=1\(st)";
                        let urlStr : NSString = url_srt.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                        print(url_srt)
                        print(urlStr)
                        if let searchURL : NSURL = NSURL(string: urlStr as String)! {
                            SingletonObject.sharedInstance.httpRequest(searchURL) {
                                (result: NSDictionary) in
                                dispatch_async(dispatch_get_main_queue()) {
                                    if let _result:NSDictionary = result{
                                        print(_result)
                                        if (_result["error"] != nil){
                                            self.error_mess("Ошибка", _message: _result["error"]! as! String)
                                        }
                                        if (_result["unsset"] != nil){
                                            self.error_mess("Ошибка", _message: "Авторизуйтесь заново.")
                                        }
                                        if (_result["ok"] != nil){
                                            self.go_out = true
                                            userDef.setObject(_result["ok"]! as! String, forKey: "hash")
                                            self.error_mess("Успех", _message: "Пароль успешно изменен!")
                                        }
                                        
                                    }
                                    else {
                                        print("error: nil result")
                                    }

                                }
                            }
                        }
                        
                    }
                    else {
                        error_mess("Ошибка", _message: "Поля с новым паролем и его подтверждением имеют различное содержание.")
                    }
                        
                }
                else {
                   error_mess("Ошибка", _message: "Заполните пустые поля.")
                }
            }
            else {
                error_mess("Ошибка", _message: "Пожалуйста авторизуйтесь заново. Скорее всего вы уже меняли свой пароль.")
            }
        }
        else {
            error_mess("Ошибка соединения!", _message: "Проверьте подключение к Интернету.")
        }
        
    }
    
    
    func popVC(){
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
    }

 
}
