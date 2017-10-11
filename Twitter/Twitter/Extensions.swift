//
//  Extensions.swift
//  Twitter
//
//  Created by Shayin Feng on 10/9/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func setButtonTitleColor(option: ButtonTitleColorOption) {
        if option == ButtonTitleColorOption.gray {
            self.setTitleColor(UIhelper.UIColorOption.gray, for: .normal)
        } else if option == ButtonTitleColorOption.green {
            self.setTitleColor(UIhelper.UIColorOption.green, for: .normal)
        } else if option == ButtonTitleColorOption.red {
            self.setTitleColor(UIhelper.UIColorOption.red, for: .normal)
        } else if option == ButtonTitleColorOption.blue {
            self.setTitleColor(UIhelper.UIColorOption.blue, for: .normal)
        } else if option == ButtonTitleColorOption.yellow {
            self.setTitleColor(UIhelper.UIColorOption.yellow, for: .normal)
        }
    }
}

extension UIView {
    // Name this function in a way that makes sense to you...
    // slideFromLeft, slideRight, slideLeftToRight, etc. are great alternative names
    func slideInFromLeft(duration: TimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: CAAnimationDelegate = completionDelegate as! CAAnimationDelegate? {
            slideInFromLeftTransition.delegate = delegate
        }
        
        // Customize the animation's properties
        slideInFromLeftTransition.type = kCATransitionPush
        slideInFromLeftTransition.subtype = kCATransitionFromLeft
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromLeftTransition.fillMode = kCAFillModeRemoved
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
}

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension Date {
    
    // Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    // Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    // Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    // Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    // Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if days(from: date) >  6 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M/dd/yy"
            return dateFormatter.string(from: date)
        }
        if days(from: date) <= 6, days(from: date) > 0 {
            return "\(days(from: date))d"
        }
        if days(from: date) <= 0, hours(from: date) > 0 {
            return "\(hours(from: date))h"
        }
        if hours(from: date) <= 0, minutes(from: date) > 0 {
            return "\(minutes(from: date))m"
        }
        if minutes(from: date) <= 0, seconds(from: date) > 0 {
            return "\(seconds(from: date))s"
        }
        return "0s"
    }
}

struct Number {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "," // or possibly "." / ","
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension Int {
    func displayCountWithFormat () -> String {
        var newNum = 0.0
        if self == 0 {
            return ""
        }
        if self >= 10000, self < 1000000 {
            newNum = Double(self) / 1000
            return "\(Number.withSeparator.string(from: NSNumber(value: (round(newNum * 10) / 10))) ?? "")K"
        }
        if self >= 1000000, self < 1000000000 {
            newNum = Double(self) / 1000000
            return "\(Number.withSeparator.string(from: NSNumber(value: (round(newNum * 10) / 10))) ?? "")M"
        }
        if self >= 1000000000 {
            newNum = Double(self) / 1000000000
            return "\(Number.withSeparator.string(from: NSNumber(value: (round(newNum * 10) / 10))) ?? "")B"
        }
        return Number.withSeparator.string(from: NSNumber(value: self)) ?? ""
    }
}
