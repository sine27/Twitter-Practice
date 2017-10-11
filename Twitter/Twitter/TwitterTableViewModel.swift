//
//  TwitterTableViewModel.swift
//  Twitter
//
//  Created by Shayin Feng on 10/9/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import Foundation

class TwitterTableViewModel: NSObject {
    
    let client = DataHandler()
    var delegate: ViewModelDelegate?
    
    /// for pagination
    var max_id = -1
    var since_id = -1
    var postEndpoint = -1
    
    var tweets: [TweetModel] = []
    
    var cellUser: UserModel?
    
    var screenName: String?
    
    var postTweet: TweetModel?
    
    var postTweetOrg: TweetModel?
    
    /// for row height estimation, used in tableView(estimatedHeightForRowAt)
    var heightAtIndexPath = NSMutableDictionary()
    
    override init() {
        postEndpoint = 0
    }
    
    func resetParamsWhenViewWillAppear() {
        cellUser = nil
        screenName = nil
    }
    
    func getNumbersOfTweets() -> Int {
        return tweets.count
    }
    
    func getTweetCellViewHeight(at indexKey: String) -> Float? {
        if let height = heightAtIndexPath.object(forKey: indexKey) as? NSNumber {
            return height.floatValue
        }
        return nil
    }
    
    func setTweetCellViewHeight(at indexKey: String, with value: Float) {
        let height = NSNumber(value: value)
        heightAtIndexPath.setObject(height, forKey: indexKey as NSCopying)
    }
    
    func getTweetModel(at index: Int) -> TweetModel {
        return tweets[index]
    }
    
    func viewModelForCell(at index: Int) -> TwitterTableCellViewModel {
        return TwitterTableCellViewModel(tweet: tweets[index])
    }
    
    func pullRefresh() {
        if since_id == -1 {
            getTweets(parameters: ["count": 20], type: .pullRefresh)
        } else {
            getTweets(parameters: ["since_id": self.since_id, "count": 5], type: .pullRefresh)
        }
    }
    
    func loadMore() {
        getTweets(parameters: ["max_id": self.max_id, "count": 10], type: .loadMore)
    }
    
    func getTweets(parameters: Any?, type: LoadType) {
        client.getTweets(parameters: parameters) { (res, error) in
            if error != nil {
                self.delegate?.presentAltertWithAction(message: error!)
            }
            else if res != nil {
                switch type {
                case .getNew:
                    self.tweets = res! + self.tweets
                    self.since_id = self.tweets[0].id!
                    self.max_id = self.tweets[self.tweets.count - 1].id!
                case .pullRefresh:
                    self.tweets = res! + self.tweets
                    self.since_id = self.tweets[0].id!
                    self.max_id = self.tweets[self.tweets.count - 1].id!
                case .loadMore:
                    var tmp = res!
                    tmp.remove(at: 0)
                    self.tweets += tmp
                    self.max_id = self.tweets[self.tweets.count - 1].id!
                }
                self.delegate?.reloadTable(section: nil, row: nil, loadType: type)
            }
            else {
                print("empty result")
            }
        }
    }
}
