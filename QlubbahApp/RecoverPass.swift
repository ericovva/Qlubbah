//
//  RecoverPass.swift
//  QlubbahApp
//
//  Created by Эрик on 27.10.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//

import UIKit

class RecoverPass: UIViewController {
    var phone: String!
    @IBOutlet weak var repeat_pass: UITextField!
    @IBOutlet weak var new_pass: UITextField!
    @IBOutlet weak var code: UITextField!
    var go_out  = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func Done(sender: AnyObject) {
        if(code.text! != "" && new_pass.text != "" && repeat_pass.text != ""){
            if (new_pass.text == repeat_pass.text){
                var st = "&pass=" + new_pass.text!
                    st += "&pass1=" + repeat_pass.text!
                    st += "&pass_code=" + code.text!
                    st += "&phone="  + phone
                let url_srt: NSString = "http://qlubbah.ru/api.php?action=pass_recover_code_write&keys=1\(st)";
                print(url_srt);
                let urlStr : NSString = url_srt.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                if let searchURL : NSURL = NSURL(string: urlStr as String)! {
                    SingletonObject.sharedInstance.httpRequest(searchURL) {
                        (result: NSDictionary) in
                        dispatch_async(dispatch_get_main_queue()) {
                            if let _result:NSDictionary = result{
                                if _result["ok"] != nil {
                                    self.go_out = true
                                    self.error_mess("Успех!", _message: "Теперь вы можете войти с новым паролем.")
                                }
                                if let tmp = _result["try"] {
                                    self.error_mess("Ошибка", _message: "У вас осталось попыток: \(tmp)")
                                }
                                if _result["try_finished"] != nil {
                                    self.go_out = true
                                    self.error_mess("Ошибка", _message: "Вы исчерпали все попытки, повторите операцию напоминания пароля.")
                                    
                                }
                            }
                        }
                    }
                }
                else {
                    print("Error: incorrect url")
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
    
    func popVC(){
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
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
