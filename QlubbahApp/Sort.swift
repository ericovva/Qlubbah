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
    @IBOutlet weak var bm: UIButton!
    @IBOutlet weak var l: UIButton!
    @IBOutlet weak var mc: UIButton!
    @IBOutlet weak var wc: UIButton!
    @IBOutlet weak var c: UIButton!

    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func name(sender: AnyObject) {
        SingletonObject.sharedInstance.sort = "name"
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func likes(sender: AnyObject) {
        SingletonObject.sharedInstance.sort = "likes"
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func men(sender: AnyObject) {
        SingletonObject.sharedInstance.sort = "female"
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func women(sender: AnyObject) {
        SingletonObject.sharedInstance.sort = "male"
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func age(sender: AnyObject) {
        SingletonObject.sharedInstance.sort = "age"
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func age_female(sender: AnyObject) {
        SingletonObject.sharedInstance.sort = "age_female"
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func people(sender: AnyObject) {
        SingletonObject.sharedInstance.sort = "people"
        navigationController?.popViewControllerAnimated(true)
    }
    
    func bordering(b:UIButton){
        b.layer.borderWidth = 2
        b.layer.borderColor = UIColor.yellowColor().CGColor
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        bordering(n)
        bordering(bg)
        bordering(bm)
        bordering(l)
        bordering(c)
        bordering(wc)
        bordering(mc)

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
