//
//  Delegate.swift
//  Twitter
//
//  Created by Shayin Feng on 10/9/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import Foundation
import UIKit

protocol ViewModelDelegate: class {
    func presentAltertWithAction(message: String)
    func reloadTable(section: Int?, row: Int?, loadType: LoadType?)
}

/**
 Used in TweetViewController for tweet detail section
 - tweetCellMenuTapped: menu for actions tapped, allowing user to delete a tweet if the tweet is post by user
 - tweetCellUserProfileImageTapped: Segue to tweet user profile
 */
@objc protocol TweetDetailTableViewCellDelegate: class {
    @objc optional func tweetCellMenuTapped(cell: TweetDetailTableViewCell, withId id: Int)
    @objc optional func tweetCellUserProfileImageTapped(cell: TweetDetailTableViewCell, forTwitterUser user: UserModel?)
}

/**
 Used in TweetViewController for tweet action section
 When action button tapped, update icon in the section (muti-thread, api called)
 */
@objc protocol TweetButtonTableViewCellDelegate: class {
    @objc optional func tweetCellFavoritedTapped(cell: TweetButtonTableViewCell, isFavorited: Bool)
    @objc optional func tweetCellRetweetTapped(cell: TweetButtonTableViewCell, isRetweeted: Bool)
    @objc optional func tweetCellReplyTapped(cell: TweetButtonTableViewCell)
}

/**
 Used in TwitterViewController
 */
@objc protocol TweetTableViewCellDelegate: class {
    @objc optional func tweetCellFavoritedTapped(cell: TweetTableViewCell, isFavorited: Bool)
    @objc optional func tweetCellRetweetTapped(cell: TweetTableViewCell, isRetweeted: Bool)
    @objc optional func tweetCellReplyTapped(cell: TweetTableViewCell, withId: Int)
    @objc optional func tweetCellMenuTapped(cell: TweetTableViewCell, withId id: Int)
    @objc optional func tweetCellUserProfileImageTapped(cell: TweetTableViewCell, forTwitterUser user: UserModel?)
    @objc optional func tweetCellMentionTapped(with screenName: String)
}

/**
 Used in both TweetViewController and TwitterViewController
 - getPopoverImage: Open the image in a pop over view controller, allowing user to enlarge a image to view the detail
 */
protocol TweetTableViewDelegate {
    func getNewTweet(data: TweetModel?)
    func getPopoverImage(imageView: UIImageView)
}

/**
 Used in TweetViewController for tweet action section
 When action button tapped, tweet detail will changed corresponsively
 */
protocol UpdateCellFromTableDelegate {
    func removeCell (indexPath: IndexPath )
    func updateNumber (tweet: TweetModel, indexPath: IndexPath)
}
