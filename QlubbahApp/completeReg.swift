//
//  completeReg.swift
//  QlubbahApp
//
//  Created by Эрик on 12.10.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//

import UIKit

class completeReg: UIViewController {

    @IBAction func completeReg(sender: AnyObject) {
        //ниже переход
        if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("pr") as? Profile{
            let navController = UINavigationController(rootViewController: secondViewController)
            navController.setViewControllers([secondViewController], animated:true)
            self.revealViewController().setFrontViewController(navController, animated: true) //если свой поставишь, поменяй на false
        
        }

    }
    @IBOutlet weak var complete: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.tintColor = UIColor.yellowColor()
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
