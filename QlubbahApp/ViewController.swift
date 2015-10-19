//
//  ViewController.swift
//  QlubbahApp
//
//  Created by Эрик on 30.09.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

   
    @IBOutlet weak var qlubbah: UILabel!
    @IBOutlet weak var yourNightVision: UILabel!
    @IBOutlet weak var enter: UIButton!
    @IBOutlet weak var reg: UIButton!
    @IBOutlet weak var ImageGif: UIImageView!
        
    func initial(){
        enter.layer.borderWidth = 1;
        enter.layer.cornerRadius = 4;
        enter.layer.borderColor = UIColor.yellowColor().CGColor
        reg.layer.borderWidth = 1;
        reg.layer.cornerRadius = 4;
        reg.layer.borderColor = UIColor.yellowColor().CGColor
        
        //var strImg : String = "http://qlubbah.ru/img/music.gif"
        let url: NSURL = NSBundle.mainBundle().URLForResource("music", withExtension: "gif")!
        let testImage = UIImage.animatedImageWithAnimatedGIFData(NSData(contentsOfURL: url))
        self.ImageGif.animationImages = testImage.images
        self.ImageGif.animationDuration = testImage.duration
        self.ImageGif.image = testImage!.images!.last as UIImage!
        self.ImageGif.startAnimating()
        self.enter.alpha = 0;
        self.reg.alpha = 0;
        self.qlubbah.alpha = 0;
        self.yourNightVision.alpha = 0;
        //self.alphaView.alpha = 0;
        
        UIView.animateWithDuration(1){
            self.enter.alpha = 0.85;
            self.reg.alpha = 0.85;
            self.qlubbah.center.y = 140;
            self.qlubbah.alpha = 0.95;
            self.yourNightVision.center.y = 240;
            self.yourNightVision.alpha = 0.95;
            //self.alphaView.alpha = 0.9;
            self.qlubbah.frame.origin.y = 400
            self.yourNightVision.frame.origin.y = 0
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initial()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }


}

