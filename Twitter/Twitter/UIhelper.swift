//
//  UIhelper.swift
//  Twitter
//
//  Created by Shayin Feng on 2/20/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

// set button title color for favorited, retweeted
enum ButtonTitleColorOption: Int {
    case green = 0, gray, red
}

extension UIButton {
    func setButtonTitleColor(option: ButtonTitleColorOption) {
        if option == ButtonTitleColorOption.gray {
            self.setTitleColor(UIColor.init(colorLiteralRed: 0.69, green: 0.73, blue: 0.75, alpha:1.0), for: .normal)
        } else if option == ButtonTitleColorOption.green {
            self.setTitleColor(UIColor.init(colorLiteralRed: 0.11, green: 0.75, blue: 0.50, alpha:1.0), for: .normal)
        } else if option == ButtonTitleColorOption.red {
            self.setTitleColor(UIColor.init(colorLiteralRed: 0.88, green: 0.23, blue: 0.40, alpha:1.0), for: .normal)
        }
    }
}

class UIhelper: NSObject {
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    let notifyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
    
    let footerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
    
    open func subviewSetup (sender : AnyObject) {
        
        spinner.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        spinner.isHidden = false
        spinner.center = sender.view.center
        spinner.startAnimating()
        spinner.alpha = 0
        
        notifyLabel.numberOfLines = 1
        notifyLabel.textColor = UIColor.init(white: 1, alpha: 0.6)
        notifyLabel.font = UIFont(name:"HelveticaNeue;", size: 30.0)
        notifyLabel.textAlignment = NSTextAlignment.center
        notifyLabel.center = sender.view.center
        notifyLabel.contentMode = UIViewContentMode.scaleAspectFit
        notifyLabel.alpha = 0
        
        footerLabel.numberOfLines = 1
        footerLabel.textColor = UIColor.init(white: 1, alpha: 0.6)
        footerLabel.font = UIFont(name:"HelveticaNeue;", size: 30.0)
        footerLabel.textAlignment = NSTextAlignment.center
        footerLabel.center.x = sender.view.center.x
        footerLabel.contentMode = UIViewContentMode.scaleAspectFit
        footerLabel.alpha = 0
    }
    
    open func activityIndicator(sender : AnyObject, style: UIActivityIndicatorViewStyle) {
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: style)
        spinner.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        spinner.isHidden = false
        spinner.center = sender.view.center
        spinner.startAnimating()
        spinner.alpha = 0
        sender.view.addSubview(spinner)
        
        UIView.animate(withDuration: 0.6, animations: {
            self.spinner.alpha = 1
        })
    }
    
    open func stopActivityIndicator() {
        spinner.stopAnimating()
        UIView.animate(withDuration: 0.4, animations: {
            self.spinner.alpha = 0
        })
        spinner.removeFromSuperview()
    }
    
    open func showNotifyLabelCenter (sender : AnyObject, notificationLabel : String, notifyType : Int) {
        
        // 0 : Not Fount
        // 1 : Reach The End
        subviewSetup(sender: sender)
        
        self.notifyLabel.alpha = 1
        notifyLabel.center.y = sender.view.center.y
        notifyLabel.text = notificationLabel
        
        if notifyType == 0 {
            
            notifyLabel.numberOfLines = 1
            
            sender.view.addSubview(notifyLabel)
        }
        else if notifyType == 1 {
            
            notifyLabel.numberOfLines = 2
            
            sender.view.addSubview(notifyLabel)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.notifyLabel.center.y = self.notifyLabel.center.y - 70
            })
        }
    }
    
    open func showNotifyLabelFooter (sender : AnyObject, notificationLabel : String, positionY : CGFloat) {
        
        footerLabel.center.y = positionY
        
        footerLabel.alpha = 1
        footerLabel.text = notificationLabel
        
        sender.view.addSubview(footerLabel)
    }
    
    open func removeNotifyLabelCenter () {
        notifyLabel.alpha = 0
        notifyLabel.removeFromSuperview()
    }
    
    open func removeNotifyLabelFooter () {
        UIView.animate(withDuration: 0.5, animations: {
            self.footerLabel.alpha = 0
        })
        footerLabel.removeFromSuperview()
    }
    
    class func displayAlertMessage(_ userTitle: String, userMessage: String, sender: AnyObject)
    {
        let myAlert = UIAlertController(title: userTitle, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        myAlert.addAction(okAction)
        sender.present(myAlert, animated:true, completion:nil)
    }
}
