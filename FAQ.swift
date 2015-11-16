//
//  FAQ.swift
//  QlubbahApp
//
//  Created by Эрик on 08.11.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//

import UIKit

class FAQ: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
//        
//        let url:NSURL = NSURL(string: "http://qlubbah.ru/info/faq.php")!
//        let request = NSURLRequest(URL: url)
//        webView.loadRequest(request)
//
//        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func webViewDidStartLoad(webView: UIWebView){
       // activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView){
        //activityIndicator.stopAnimating()
        //activityIndicator.hidden = true
    }
    
    

}
