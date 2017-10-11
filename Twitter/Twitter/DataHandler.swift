//
//  DataHandler.swift
//  Twitter
//
//  Created by Shayin Feng on 10/10/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import Foundation

class DataHandler: NSObject {
    
    let client = TwitterClient.sharedInstance!
    
    func requestData(parameters: Any?, completed: @escaping (Any?, String?) -> ()) {
        if let client = TwitterClient.sharedInstance {
            DispatchQueue.global(qos: .userInitiated).async {
                client.get(TwitterClient.APIScheme.HomeTimelineEndpoint, parameters: parameters, progress: nil, success: { (task, response) in
                    debugPrint(response)
                    return completed(response, nil)
                }, failure: { (task, error) in
                    return completed(nil, error.localizedDescription)
                })
            }
        }
    }
    
    func getTweets(parameters: Any?, completed: @escaping ([TweetModel]?, String?) -> ()) {
        requestData(parameters: parameters ?? [:]) { (response, error) in
            if error != nil {
                return completed(nil, error)
            }
            let dictionary = response as! [NSDictionary]
            
            var tweetsTmp: [TweetModel] = []
            for tweet in dictionary {
                tweetsTmp.append(TweetModel(dictionary: tweet))
            }
            return completed(tweetsTmp, nil)
        }
        
    }
}
