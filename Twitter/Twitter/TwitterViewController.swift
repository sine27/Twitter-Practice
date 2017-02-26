//
//  TwitterViewController.swift
//  Twitter
//
//  Created by Shayin Feng on 2/21/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import ESPullToRefresh

class TwitterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, SubviewViewControllerDelegate {
    
    @IBOutlet weak var twitterTableView: UITableView!
    
    var max_id = -1
    
    var since_id = -1
    
    var tweets: [TweetModel] = []
    
    var uiHelper = UIhelper()
    
    var parameters: Any?
    
    var heightAtIndexPath = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        twitterTableView.delegate = self
        twitterTableView.dataSource = self
        
        twitterTableView.layoutMargins = UIEdgeInsets.zero
        twitterTableView.separatorInset = UIEdgeInsets.zero
        
        twitterTableView.alpha = 0
        self.uiHelper.stopActivityIndicator()
        uiHelper.activityIndicator(sender: self, style: UIActivityIndicatorViewStyle.gray)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        let imageView = UIImageView(image: UIImage(named: "TwitterLogoBlue"))
        
        imageView.layer.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        imageView.contentMode = .scaleAspectFit
        
        self.navigationItem.titleView = imageView
            
        // auto adjust table cell height
        twitterTableView.rowHeight = UITableViewAutomaticDimension
        twitterTableView.estimatedRowHeight = 80
        
        twitterTableView.es_addPullToRefresh {
            if self.since_id == -1 {
                self.parameters = ["count": 20]
            } else {
                self.parameters = ["since_id": self.since_id, "count": 5]
            }
            self.requestData(parameters: self.parameters, type: 0)
        }
        
        twitterTableView.es_addInfiniteScrolling {
            if self.max_id == -1 {
                self.twitterTableView.es_noticeNoMoreData()
            } else {
                self.parameters = ["max_id": self.max_id, "count": 10]
                self.requestData(parameters: self.parameters, type: 1)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.twitterTableView.es_startPullToRefresh()
        }
        
        // Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(TwitterViewController.onTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // deselect cell when push back
        let selectedIndexPath = twitterTableView.indexPathForSelectedRow
        if selectedIndexPath != nil {
            twitterTableView.deselectRow(at: selectedIndexPath!, animated: false)
        }
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.tintColor = UIhelper.UIColorOption.twitterBlue
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
    }
    
    func onTimer() {
        // Add code to be run periodically
        // requestData(parameters: parameters, type: 2)
        if tweets.count != 0 {
            let offset = self.twitterTableView.contentOffset
            twitterTableView.reloadData()
            twitterTableView.layoutIfNeeded()
            twitterTableView.contentOffset = offset
        }
    }
    
    func requestData (parameters: Any?, type: Int) {
        
        if let client = TwitterClient.sharedInstance {
            client.get(TwitterClient.APIScheme.HomeTimelineEndpoint, parameters: parameters, progress: nil, success: { (task, response) in

                let dictionary = response as! [NSDictionary]
        
                var tweetsTmp: [TweetModel] = []
                for tweet in dictionary {
                    tweetsTmp.append(TweetModel(dictionary: tweet))
                }
                
                if type == 0 {
                    self.tweets = tweetsTmp + self.tweets
                    
                    self.since_id = self.tweets[0].id!
                    self.max_id = self.tweets[self.tweets.count - 1].id!
                    
                    self.twitterTableView.reloadData()
                    self.twitterTableView.es_stopPullToRefresh()
                }
                else if type == 1 {
                    
                    tweetsTmp.remove(at: 0)
                    
                    self.tweets += tweetsTmp
                    
                    self.max_id = self.tweets[self.tweets.count - 1].id!
                    self.twitterTableView.reloadData()
                    self.twitterTableView.es_stopLoadingMore()
                }
                else if type == 2 {
                    self.tweets = tweetsTmp + self.tweets
                    
                    self.since_id = self.tweets[0].id!
                    self.max_id = self.tweets[self.tweets.count - 1].id!
                    
                    let offset = self.twitterTableView.contentOffset
                    self.twitterTableView.reloadData()
                    self.twitterTableView.layoutIfNeeded()
                    self.twitterTableView.contentOffset = offset
                }
                
                self.uiHelper.stopActivityIndicator()
                UIView.animate(withDuration: 1.0, animations: {
                    self.twitterTableView.alpha = 1
                })
            }, failure: { (task, error) in
                UIhelper.alertMessage("Request", userMessage: error.localizedDescription, action: nil, sender: self)
                print("FetchTimelineData: Error >>> \(error.localizedDescription)")
                self.uiHelper.stopActivityIndicator()
                
                if type == 0 {
                    self.twitterTableView.es_stopPullToRefresh()
                } else if type == 1 {
                    self.twitterTableView.es_stopLoadingMore()
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "twitterCell") as! TwitterTableViewCell
        
        let tweet = tweets[indexPath.row]
        
        if tweet.isUserRetweeted! == true {
            cell.reTwitteButton.imageView?.image = #imageLiteral(resourceName: "retweet-icon-green")
        } else {
            cell.reTwitteButton.imageView?.image = #imageLiteral(resourceName: "retweet-icon")
        }
        
        if tweet.isUserFavorited! == true {
            cell.favoriteButton.imageView?.image = #imageLiteral(resourceName: "favor-icon-red")
        } else {
            cell.favoriteButton.imageView?.image = #imageLiteral(resourceName: "favor-icon")
        }
        
        if let timeCreated = tweet.createdAt {
            let now = Date()
            let difference = now.offset(from: timeCreated)
            cell.timeCreateLabel.text = difference
        } else {
            cell.timeCreateLabel.text = "unkown"
        }
        
        if let retweeted_status = tweet.retweeted_status {
            cell.userTweetForRetweet = tweet
            cell.tweet = retweeted_status
        } else {
            cell.tweet = tweet
        }
        
        cell.index = indexPath
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
            return CGFloat(height.floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let height = NSNumber(value: Float(cell.frame.size.height))
        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logoutTapped(_ sender: Any) {
        
        UIhelper.alertMessageWithAction("Log Out", userMessage: "Are you sure to logout?", left: "Cancel", right: "Logout", leftAction: nil, rightAction: { (action) in
            if let client = TwitterClient.sharedInstance {
                client.logout()
            }
        }, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTwitterDetail" {
            let vc = segue.destination as! TweetViewController
            
            let indexPath = twitterTableView.indexPathForSelectedRow
            if let index = indexPath {
                vc.tweet = self.tweets[index.row]
            }
        }
        // popover segue
        if segue.identifier == "popoverSegue" {
            let popoverViewController = segue.destination as! PostViewController
            popoverViewController.delegate = self
            popoverViewController.popoverPresentationController?.delegate = self
            popoverViewController.endpoint = 0
        }
    }
    
    func getNewTweet(data: TweetModel) {
        // print(data.dictionary)
        requestData(parameters: ["since_id": since_id], type: 2)
    }
    
    func removeCell(index: IndexPath) {
        print("herrrr")
        tweets.remove(at: index.row)
        twitterTableView.deleteRows(at: [index], with: .fade)
    }
    
    func showAlter(alertController: UIAlertController) {
        self.present(alertController, animated: true, completion: nil)
    }
}
