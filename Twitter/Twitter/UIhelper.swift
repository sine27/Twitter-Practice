//
//  UIhelper.swift
//  Twitter
//
//  Created by Shayin Feng on 2/20/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit



class UIhelper: NSObject {
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    let notifyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
    
    let footerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
    
    var footerImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    
    struct UIColorOption {
        static let gray = UIColor(red: 0.69, green: 0.73, blue: 0.75, alpha: 1.0)
        static let green = UIColor(red: 0.11, green: 0.75, blue: 0.50, alpha: 1.0)
        static let red = UIColor(red: 0.88, green: 0.23, blue: 0.40, alpha: 1.0)
        static let blue = UIColor(red: 0.28, green: 0.56, blue: 0.76, alpha: 1.0)
        static let yellow = UIColor(red: 0.95, green: 0.84, blue: 0.0, alpha: 1.0)
        static let twitterBlue = UIColor(red: 0.35, green: 0.69, blue: 0.95, alpha: 1.0)
        static let twitterGray = UIColor(red: 0.38, green: 0.45, blue: 0.51, alpha: 1.0)
    }
    
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
    
    open func showTwitterFooter (sender : AnyObject, positionX: CGFloat, positionY : CGFloat) {
        
        footerImage = UIImageView(frame: CGRect(x: positionX, y: positionY, width: 50, height: 50))
        
        footerImage.image = #imageLiteral(resourceName: "twitter")
        
        sender.view.addSubview(footerImage)
    }
    
    open func removeTwitterFooter () {
        footerImage.removeFromSuperview()
    }
    
    class func alertMessage(_ userTitle: String, userMessage: String, action: ((UIAlertAction) -> Void)?, sender: AnyObject)
    {
        let myAlert = UIAlertController(title: userTitle, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: action)
        myAlert.addAction(okAction)
        sender.present(myAlert, animated: true, completion: nil)
    }
    
    class func alertMessageWithAction(_ userTitle: String, userMessage: String, left: String, right: String, leftAction: ((UIAlertAction) -> Void)?, rightAction: ((UIAlertAction) -> Void)?, sender: AnyObject)
    {
        let myAlert = UIAlertController(title: userTitle, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        myAlert.addAction(UIAlertAction(title: left, style: .cancel, handler: leftAction))
        
        myAlert.addAction(UIAlertAction(title: right, style: .destructive, handler: rightAction))
        sender.present(myAlert, animated: true, completion: nil)
    }
    
    class func cornerOfStackImage (sender: AnyObject, photoCount: Int, contentStack0: UIStackView, contentStack1: UIStackView, frameHeight: CGFloat) {
        sender.layoutIfNeeded()
        switch photoCount {
        case 1:
            contentStack0.subviews[0].heightAnchor.constraint(equalToConstant: frameHeight).isActive = true
            contentStack0.subviews[0].roundCorners(corners: .allCorners, radius: 5)
            
        case 2:
            contentStack0.subviews[0].heightAnchor.constraint(equalToConstant: frameHeight).isActive = true
            contentStack1.subviews[0].heightAnchor.constraint(equalToConstant: frameHeight).isActive = true
            contentStack0.subviews[0].roundCorners(corners: [.topLeft, .bottomLeft], radius: 5)
            contentStack1.subviews[0].roundCorners(corners: [.topRight, .bottomRight], radius: 5)
            
        case 3:
            contentStack0.subviews[0].heightAnchor.constraint(equalToConstant: frameHeight).isActive = true
            contentStack1.subviews[0].heightAnchor.constraint(equalToConstant: frameHeight / 2).isActive = true
            contentStack1.subviews[1].heightAnchor.constraint(equalToConstant: frameHeight / 2).isActive = true
            contentStack0.subviews[0].roundCorners(corners: [.topLeft, .bottomLeft], radius: 5)
            contentStack1.subviews[0].roundCorners(corners: .topRight, radius: 5)
            contentStack1.subviews[1].roundCorners(corners: .bottomRight, radius: 5)
            
        case 4:
            contentStack0.subviews[0].heightAnchor.constraint(equalToConstant: frameHeight / 2).isActive = true
            contentStack0.subviews[1].heightAnchor.constraint(equalToConstant: frameHeight / 2).isActive = true
            contentStack1.subviews[0].heightAnchor.constraint(equalToConstant: frameHeight / 2).isActive = true
            contentStack1.subviews[1].heightAnchor.constraint(equalToConstant: frameHeight / 2).isActive = true
            contentStack0.subviews[0].roundCorners(corners: .topLeft, radius: 5)
            contentStack1.subviews[0].roundCorners(corners: .topRight, radius: 5)
            contentStack1.subviews[1].roundCorners(corners: .bottomRight, radius: 5)
            contentStack0.subviews[1].roundCorners(corners: .bottomLeft, radius: 5)
            
        default: () }
    }
}
