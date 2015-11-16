//
//  MyNumber.swift
//  QlubbahApp
//
//  Created by Эрик on 26.10.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//

import UIKit

class MyNumber: UIViewController {

    @IBOutlet weak var phone: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController!.navigationBar.tintColor = UIColor.yellowColor()
        self.phone.keyboardType = UIKeyboardType.PhonePad
        self.phone.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func error_mess(_title: String,_message: String){
        let alert = UIAlertController(title: _title, message: _message, preferredStyle: UIAlertControllerStyle.Alert)
        //alert.view.backgroundColor = UIColor.darkGrayColor()
        let okButton = UIAlertAction(title: "Закрыть", style: UIAlertActionStyle.Default) { (okSelected) -> Void in
     
        }
        alert.addAction(okButton)
        //alert.addAction(UIAlertAction(title: "Закрыть", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
        
    }
    

    @IBAction func next(sender: AnyObject) {
        if (Reachability.isConnectedToNetwork()){
          
                if (phone.text!.characters.count == 10){
                    let st = "&phone=" + phone.text!
                    let url_srt: NSString = "http://qlubbah.ru/api.php?action=pass_recover_phone_write&keys=1\(st)";
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
                                        self.error_mess("Ошибка", _message: _result["error"] as! String)
                                    }
                                    if (_result["phone"] != nil){
                                        self.performSegueWithIdentifier("go_to_change", sender: nil)
                                        print("SDAS")
                                    }
                                }
                            }
                        }
                    }
                    
                }
                else {
                    error_mess("Ошибка", _message: "Неверный телефонный формат, предполагается ввести (код оператора) и 7-значный номер.")
                }
            
        }
        else{
            error_mess("Соединение отсутсвует", _message: "Проверьте соеинение к Интернету.")
        }

    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        print("SDAS")
        if segue.identifier == "go_to_change" {print("SDAS")
            let svc = segue.destinationViewController as! RecoverPass;
            svc.phone = phone.text
            print("SDAS")
        }

    }

}
