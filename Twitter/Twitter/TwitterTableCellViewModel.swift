//
//  TwitterTableCellViewModel.swift
//  Twitter
//
//  Created by Shayin Feng on 10/9/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import Foundation

class TwitterTableCellViewModel {

    var tweetForShow: TweetModel!
    
    var tweet: TweetModel!
    
    let client = TwitterClient.sharedInstance!
    
    var index: IndexPath!
    
    var videoUrl: String?
    
    init(tweet: TweetModel) {
        self.tweet = tweet
        if let retweeted_status = tweet.retweeted_status {
            tweetForShow = tweet
            self.tweet = retweeted_status
        } else {
            tweetForShow = tweet
        }
    }
    
    func isTweetRetweeted() -> Bool {
        return tweetForShow.isUserRetweeted ?? false
    }
    
    func isTweetFavorited() -> Bool {
        return tweetForShow.isUserFavorited ?? false
    }
    
    func getTimePosted() -> String {
        if let timeCreated = tweet.createdAt {
            return "\(Date().offset(from: timeCreated))"
        }
        return ""
    }
    
    func getRetweetNote() -> String? {
        if isTweetRetweeted(), tweetForShow.user?.name == tweet.user?.name {
            return nil
        }
        if let username = tweetForShow.user?.name {
            return username == UserModel.currentUser!.name ? " You Retweeted":" \(username) Retweeted"
        }
        return nil
    }
    
    func getAvatarImageURL(withHttps: Bool) -> URL? {
        return withHttps ? tweet.user?.profile_image_url_https:tweet.user?.profile_image_url
    }
    
    func isUserVerified() -> Bool {
        if tweet.user?.name != nil {
            return tweet.user?.verified ?? false
        }
        return false
    }
    
    func getUsername() -> String {
        if let nameString = tweet?.user?.name {
            return nameString
        }
        return ""
    }
    
    func getScreenName() -> String {
        if let screenName = tweet?.user?.screen_name {
            return screenName
        }
        return ""
    }
    
    func hasMedia() -> Bool {
        return tweetForShow.media != nil
    }
    
    func getContentAfterMediaUrlReplaced(with media: MediaModel, content: String) -> String {
        if let range = content.range(of: media.url_should_be_replaced) {
            return content.replacingCharacters(in: range, with: "")
        }
        return content
    }
    
    func getVideoUrlString(with media: MediaModel) -> String {
        let video_info = media.video_info
        let variants = video_info!["variants"] as! [NSDictionary]
        let variant = variants[0]
        return variant["url"] as! String
    }
}
