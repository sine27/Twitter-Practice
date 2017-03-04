//
//  UserModel.swift
//  Twitter
//
//  Created by Shayin Feng on 2/21/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

class UserModel: NSObject {
    
    var create_at: Date?
    var use_description: String?
    var favourites_count: Int?
    var followers_count: Int?
    var friend_count: Int?
    var geo_enabled: Bool?
    var id: Int?
    var listed_count: Int?
    var statuses_count: Int?
    var location: String?
    var name: String?
    var profile_background_color: String?
    var profile_background_image_url: URL?
    var profile_background_image_url_https: URL?
    var profile_image_url: URL?
    var profile_image_url_https: URL?
    var screen_name: String?
    var dictionary: NSDictionary
    var verified: Bool?
    var hashtags: NSArray?
    var media: NSArray?
    var symbols: NSArray?
    var urls: NSArray?
    var user_mentions: NSArray?
    var description_link: String?
    
    // Add more variables
    
    
    init(dictionary: NSDictionary) {
        
        self.dictionary = dictionary
        
        if let verified = dictionary["verified"] as? Bool {
            self.verified = verified
        } else {
            self.verified = false
        }
        
        if let createAtString = dictionary["created_at"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
            dateFormatter.locale = Locale.current
            self.create_at = dateFormatter.date(from: createAtString)
        } else {
            self.create_at = nil
        }
        
        if let userDescriptionString = dictionary["description"] as? String {
            self.use_description = userDescriptionString
        } else {
            self.use_description = nil
        }
        
        if let favouritesCount = dictionary["favourites_count"] as? Int {
            self.favourites_count = favouritesCount
        } else {
            self.favourites_count = 0
        }
        
        if let followersCount = dictionary["followers_count"] as? Int {
            self.followers_count = followersCount
        } else {
            self.followers_count = 0
        }
        
        if let friendCount = dictionary["friends_count"] as? Int {
            self.friend_count = friendCount
        } else {
            self.friend_count = 0
        }
        
        if let statuses_count = dictionary["statuses_count"] as? Int {
            self.statuses_count = statuses_count
        } else {
            self.statuses_count = 0
        }
        
        if let geoEnabled = dictionary["geo_enabled"] as? Bool {
            self.geo_enabled = geoEnabled
        } else {
            geo_enabled = false
        }
        
        if let id = dictionary["id"] as? Int? {
            self.id = id
        } else {
            self.id = nil
        }
        
        if let listedCount = dictionary["listed_count"] as? Int? {
            self.listed_count = listedCount
        } else {
            self.listed_count = nil
        }
        
        if let location = dictionary["location"] as? String? {
            self.location = location
        } else {
            self.location = nil
        }
        
        if let name = dictionary["name"] as? String? {
            self.name = name
        } else {
            self.name = nil
        }
        
        if let profile_background_color = dictionary["profile_background_color"] as? String? {
            self.profile_background_color = profile_background_color
        } else {
            self.profile_background_color = nil
        }
        
        if let profile_background_image_url = dictionary["profile_background_image_url"] as? String? {
            self.profile_background_image_url = URL(string: profile_background_image_url!)
        } else {
            self.profile_background_image_url = nil
        }
        
        if let profile_background_image_url_https = dictionary["profile_background_image_url_https"] as? String? {
            self.profile_background_image_url_https = URL(string: profile_background_image_url_https!)
        } else {
            if let profile_banner_url = dictionary["profile_banner_url"] as? String? {
                self.profile_background_image_url_https = URL(string: profile_banner_url!)
            } else {
                self.profile_background_image_url_https = nil
            }
        }
        
        if let profile_image_url = dictionary["profile_image_url"] as? String? {
            let new_profile_image_url = profile_image_url!.replacingOccurrences(of: "_normal", with: "")
            self.profile_image_url = URL(string: new_profile_image_url)
        } else {
            self.profile_image_url = nil
        }
        
        if let profile_image_url_https = dictionary["profile_image_url_https"] as? String? {
            let new_profile_image_url_https = profile_image_url_https!.replacingOccurrences(of: "_normal", with: "")
            self.profile_image_url_https = URL(string: new_profile_image_url_https)
        } else {
            self.profile_image_url_https = nil
        }
        
        if let screen_name = dictionary["screen_name"] as? String? {
            self.screen_name = "@\(screen_name!)"
        } else {
            self.screen_name = nil
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
    
    static let userDidLogoutNotification = "UserDidLogout"
    
    static var _currentUser: UserModel?
    
    class var currentUser : UserModel? {
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                if let userData = defaults.object(forKey: "twitter_current_user") as? Data {
                    do {
                        let data = try JSONSerialization.jsonObject(with: userData, options: .allowFragments) as? NSDictionary
                        _currentUser = UserModel(dictionary: data!)
                    } catch {
                        print("Try Catch: User not found")
                        _currentUser = nil
                    }
                }
            }
            return _currentUser
        }
        set (user) {
            _currentUser = user
            
            let defaults = UserDefaults.standard
            
            if let user = user {
                do {
                    let data = try JSONSerialization.data(withJSONObject: user.dictionary, options: [])
                    defaults.set(data, forKey: "twitter_current_user")
                } catch {
                    defaults.set(nil, forKey: "twitter_current_user")
                }
            } else {
                defaults.set(nil, forKey: "twitter_current_user")
            }
            defaults.synchronize()
        }
    }
}
