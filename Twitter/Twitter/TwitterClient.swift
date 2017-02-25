//
//  twitterClient.swift
//  Twitter
//
//  Created by Shayin Feng on 2/20/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import AFNetworking
import BDBOAuth1Manager
import CoreLocation

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: URL(string: "https://api.twitter.com")!, consumerKey: "GA7uRToJE2eK6uXMTQSDLt62y", consumerSecret: "XnSjp3wOW6DnfAqjp5dLLz70kMFn0N1DwU6EAGIudx9z3AGqZq")
    
    var loginSuccess : (() -> ())?
    var loginFailure : ((Error) -> ())?
    
    struct APIScheme {
        static let callbackUrl = URL(string: "twitterdemo://oauth")
        
        static let BaseUrl = URL(string: "https://api.twitter.com")
        static let UploadUrl = URL(string: "https://upload.twitter.com")
        
        static let OAuthRequestTokenEndpoint = "oauth/request_token"
        static let OAuthAccessTokenEndpoint = "oauth/access_token"
        static let UserCredentialEndpoint = "1.1/account/verify_credentials.json"
        
        static let HomeTimelineEndpoint = "1.1/statuses/home_timeline.json"
        static let MentionsTimelineEndpoint = "1.1/statuses/mentions_timeline.json"
        
        static let ShowStatusEndpoint = "1.1/statuses/show/:id.json"
        static let UpdateStatusEndpoint = "1.1/statuses/update.json"
        
        static let RetweetStatusEndpoint = "1.1/statuses/retweet/:id.json"
        static let UnretweetStatusEndpoint = "1.1/statuses/unretweet/:id.json"
        static let TweetStatusUpdateEndpoint = "1.1/statuses/update.json"
        static let TweetStatusDestroyEndpoint = "1.1/statuses/destroy/:id.json"
        
        static let FavoriteCreateEndpoint = "1.1/favorites/create.json"
        static let FavoriteDestroyEndpoint = "1.1/favorites/destroy.json"
        
        static let MediaUploadEndpoint = "1.1/media/upload.json"
        static let DirectMessagePostEndpoint = "1.1/direct_messages/new.json"
    }
    
    func fetchRequestTokenForLoggin (success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        
        loginSuccess = success
        loginFailure = failure
        
        if let client = TwitterClient.sharedInstance {
            
            client.deauthorize()
            
            client.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitterdemo://oauth")!, scope: nil, success: { (requestToken) in
                
                if let token = requestToken?.token {
                    print("fetchRequestToken: Success")
                    
                    // switch out of the app
                    let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(token)")!
                    
                    UIApplication.shared.openURL(url)

                }
                
            }, failure: { (error) in
                print("fetchRequestToken: Error >>> \(error?.localizedDescription ?? "Unkown")")
                self.loginFailure?(error!)
            })
        }
    }
    
    func handleOpenUrl (url: URL) {
        
        if let requestToken = BDBOAuth1Credential(queryString: url.query) {
            
            fetchAccessToken(withPath: TwitterClient.APIScheme.OAuthAccessTokenEndpoint, method: "POST", requestToken: requestToken, success: { (accessToken) in
                
                self.currentUserSetup(success: { (user) in
                    
                    UserModel.currentUser = user
                
                    self.loginSuccess?()
                    
                }, failure: { (error) in
                    self.loginFailure?(error)
                })
                
            }, failure: { (error) in
                print("fetchAccessToken: Error >>> \(error?.localizedDescription ?? "no error?")")
                self.loginFailure?(error!)
            })
        }
    }
    
    func currentUserSetup (success: @escaping (UserModel) -> (), failure: @escaping (Error) -> ()) {
        get(TwitterClient.APIScheme.UserCredentialEndpoint, parameters: nil, progress: nil, success: { (task, response) in
            if let userDictionary = response as? NSDictionary {
                let user = UserModel(dictionary: userDictionary)
                success(user)
            }
        }) { (task, error) in
            failure(error)
        }
    }

    func logout () {
        UserModel.currentUser = nil
        deauthorize()
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "twitter_current_user")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UserModel.userDidLogoutNotification), object: nil)
    }
}
