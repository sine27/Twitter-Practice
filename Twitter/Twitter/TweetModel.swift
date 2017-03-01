//
//  TweetModel.swift
//  Twitter
//
//  Created by Shayin Feng on 2/21/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

class TweetModel: NSObject {
    var id: Int?
    var text: String?
    var user: UserModel?
    var createdAt: Date?
    
    var retweetCount: Int?
    var isUserRetweeted: Bool?
    // var retweetId: Int?
    
    var favoriteCount: Int?
    var isUserFavorited: Bool?
    
    var hashtags: NSArray?
    var media: NSArray?
    var symbols: NSArray?
    var urls: NSArray?
    var user_mentions: NSArray?
    
    var retweeted_status: TweetModel?
    
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary) {
        
        self.dictionary = dictionary
        
        if let retweeted_status = dictionary["retweeted_status"] as? NSDictionary {
            self.retweeted_status = TweetModel(dictionary: retweeted_status)
        } else {
            self.retweeted_status = nil
        }
        
        if let id = dictionary["id"] as? Int {
            self.id = id
        } else {
            self.id = nil
        }
        
        if let createAtString = dictionary["created_at"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E MMM d HH:mm:ss Z yyyy"
            self.createdAt = dateFormatter.date(from: createAtString)
        } else {
            self.createdAt = nil
        }
        
        if let user = dictionary["user"] as? NSDictionary {
            self.user = UserModel(dictionary: user)
        } else {
            self.user = nil
        }
        
        if let text = dictionary["text"] as? String {
            self.text = text
        } else {
            self.text = nil
        }
        
        if let retweetCount = dictionary["retweet_count"] as? Int {
            self.retweetCount = retweetCount
        } else {
            self.retweetCount = 0
        }
        
        if let isUserRetweeted = dictionary["retweeted"] as? Bool {
            self.isUserRetweeted = isUserRetweeted
        } else {
            self.isUserRetweeted = false
        }
        
        if let favoriteCount = dictionary["favorite_count"] as? Int {
            self.favoriteCount = favoriteCount
        } else {
            self.favoriteCount = 0
        }
        
        if let isUserFavorited = dictionary["favorited"] as? Bool {
            self.isUserFavorited = isUserFavorited
        } else {
            self.isUserFavorited = false
        }
        
        if var entities = dictionary["entities"] as? NSDictionary {
            
            if let hashtags = entities["hashtags"] as? NSArray {
                self.hashtags = hashtags
            } else {
                self.hashtags = nil
            }
            
            if let symbols = entities["symbols"] as? NSArray {
                self.symbols = symbols
            } else {
                self.symbols = nil
            }
            
            if let urls = entities["urls"] as? NSArray {
                self.urls = urls
            } else {
                self.urls = nil
            }
            
            if let user_mentions = entities["user_mentions"] as? NSArray {
                self.user_mentions = user_mentions
            } else {
                self.user_mentions = nil
            }
            
            if let extended_entities = dictionary["extended_entities"] as? NSDictionary {
                entities = extended_entities
            }
            
            if let media = entities["media"] as? NSArray {
                self.media = media
            } else {
                self.media = nil
            }
        }
    }
}
