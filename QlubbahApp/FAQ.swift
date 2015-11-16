//
//  FAQ.swift
//  QlubbahApp
//
//  Created by Эрик on 08.11.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//

import UIKit

class FAQ: UIWebView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    func webViewDidStartLoad(webView: UIWebView){
        activityIndicator.startAnimating()
    }

}
