//
//  Sort.swift
//  QlubbahApp
//
//  Created by Эрик on 11.10.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//

import UIKit

class Sort: UIViewController {
    @IBOutlet weak var n: UIButton!
    @IBOutlet weak var bg: UIButton!
   
    @IBOutlet weak var l: UIButton!
    @IBOutlet weak var mc: UIButton!
    @IBOutlet weak var wc: UIButton!
    @IBOutlet weak var c: UIButton!

    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func name(sender: AnyObject) {
        high_light(n)
        SingletonObject.sharedInstance.sort = "name"
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func likes(sender: AnyObject) {
        high_light(l)
        SingletonObject.sharedInstance.sort = "likes"
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func men(sender: AnyObject) {
        high_light(bg)
        SingletonObject.sharedInstance.sort = "female"
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func age(sender: AnyObject) {
        high_light(mc)
        SingletonObject.sharedInstance.sort = "people"
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func age_female(sender: AnyObject) {
        high_light(wc)
        SingletonObject.sharedInstance.sort = "mid_age"
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func people(sender: AnyObject) {
        high_light(c)
        SingletonObject.sharedInstance.sort = "male"
        navigationController?.popViewControllerAnimated(true)
    }
    
    func bordering(b:UIButton){
        b.layer.borderWidth = 2
        b.layer.cornerRadius = 7
        b.layer.borderColor = UIColor.yellowColor().CGColor
    }
    func high_light(button: UIButton){
        nonLight_all()
        button.backgroundColor = UIColor.yellowColor()
        button.setTitleColor(UIColor.blackColor(),forState: UIControlState.Normal)
        
    }
    func nonLight_all(){
        n.backgroundColor = UIColor.blackColor()
        n.setTitleColor(UIColor.yellowColor(),forState: UIControlState.Normal)
        l.backgroundColor = UIColor.blackColor()
        l.setTitleColor(UIColor.yellowColor(),forState: UIControlState.Normal)
        bg.backgroundColor = UIColor.blackColor()
        bg.setTitleColor(UIColor.yellowColor(),forState: UIControlState.Normal)
        mc.backgroundColor = UIColor.blackColor()
        mc.setTitleColor(UIColor.yellowColor(),forState: UIControlState.Normal)
        wc.backgroundColor = UIColor.blackColor()
        wc.setTitleColor(UIColor.yellowColor(),forState: UIControlState.Normal)
        c.backgroundColor = UIColor.blackColor()
        c.setTitleColor(UIColor.yellowColor(),forState: UIControlState.Normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bordering(n)
        bordering(bg)
    
        bordering(l)
        bordering(c)
        bordering(wc)
        bordering(mc)
        switch( SingletonObject.sharedInstance.sort ){
            case "likes": l.backgroundColor = UIColor.yellowColor()
                          l.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    
        case "female": bg.backgroundColor = UIColor.yellowColor()
        bg.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        case "people": mc.backgroundColor = UIColor.yellowColor()
        mc.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        case "mid_age": wc.backgroundColor = UIColor.yellowColor()
        wc.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        case "male": c.backgroundColor = UIColor.yellowColor()
        
        c.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            default: n.backgroundColor = UIColor.yellowColor()
                     n.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
