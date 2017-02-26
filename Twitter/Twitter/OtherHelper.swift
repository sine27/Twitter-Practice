//
//  OtherHelper.swift
//  Twitter
//
//  Created by Shayin Feng on 2/21/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

protocol SubviewViewControllerDelegate {
    func getNewTweet(data: TweetModel)
    func removeCell(index: IndexPath)
    func showAlter(alertController: UIAlertController)
}

protocol PreviewViewDelegate {
    func getPopoverImage(imageView: UIImageView)
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
            return "\(days(from: date))d"
        }
        if days(from: date) <= 6, hours(from: date) > 0 {
            return "\(hours(from: date))h"
        }
        if hours(from: date) <= 0, minutes(from: date) > 0 {
            return "\(minutes(from: date))m"
        }
        if minutes(from: date) <= 0, seconds(from: date) > 0 {
            return "\(seconds(from: date))s"
        }
        return ""
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

class OtherHelper: NSObject {

}
