//
//  TwitterViewController.swift
//  Twitter
//
//  Created by Shayin Feng on 2/21/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import ESPullToRefresh
import AVKit
import AVFoundation

class TwitterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, TweetsTableViewCellDelegate, TweetTableViewDelegate, UpdateCellFromTableDelegate {
    
    @IBOutlet weak var twitterTableView: UITableView!
    
    var max_id = -1
    
    var since_id = -1
    
    var tweets: [TweetModel] = []
    
    var uiHelper = UIhelper()
    
    var parameters: Any?
    
    var heightAtIndexPath = NSMutableDictionary()
    
    var popImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        twitterTableView.delegate = self
        twitterTableView.dataSource = self
        
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
        
        self.navigationController!.navigationBar.topItem?.title = ""
        self.navigationController!.title = "Tweet"
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
                // print("FetchTimelineData: Error >>> \(error.localizedDescription)")
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
        
        cell.popDelegate = self
        
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
                if let retweeted_status = self.tweets[index.row].retweeted_status {
                    vc.tweet = retweeted_status
                    vc.retweet = self.tweets[index.row]
                } else {
                    vc.tweet = self.tweets[index.row]
                }
                vc.indexPath = index
                vc.delegate = self
            }
        }
        // popover segue
        if segue.identifier == "popoverSegue" {
            let popoverViewController = segue.destination as! PostViewController
            popoverViewController.delegate = self
            popoverViewController.popoverPresentationController?.delegate = self
            popoverViewController.endpoint = 0
        }
        // popover segue
        if segue.identifier == "showImage" {
            let popoverViewController = segue.destination as! PreviewViewController
            popoverViewController.delegate = self
            popoverViewController.popoverPresentationController?.delegate = self
            popoverViewController.image = popImage
        }
    }

    func tweetCellRetweetTapped(cell: TwitterTableViewCell, isRetweeted: Bool) {
        var endpoint : String?
        
        // pop up menu
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        cell.reTwitteButton.isEnabled = false
        cell.numRetwitteLabel.isEnabled = false
        
        let tweetid = cell.tweet.id!
        var title = "Retweet"
        var style = UIAlertActionStyle.default
        
        if cell.tweet.isUserRetweeted! {
            title = "Unretweet"
            style = UIAlertActionStyle.destructive
            endpoint = TwitterClient.APIScheme.UnretweetStatusEndpoint
        } else {
            endpoint = TwitterClient.APIScheme.RetweetStatusEndpoint
        }
        
        if let range = endpoint?.range(of: ":id") {
            endpoint = endpoint?.replacingCharacters(in: range, with: "\(tweetid)")
        }
        
        let retweetAction = UIAlertAction(title: title, style: style) { (action) in
            
            cell.reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon-blue"), for: .normal)
            cell.numRetwitteLabel.setButtonTitleColor(option: .blue)
            
            cell.client.post(endpoint!, parameters: nil, progress: nil, success: { (task, response) in
                print("retweet: success")
                
                var count = cell.tweet.retweetCount!
                
                if cell.tweet.isUserRetweeted! {
                    cell.reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon"), for: .normal)
                    cell.numRetwitteLabel.setButtonTitleColor(option: .gray)
                    count -= 1
                    cell.tweet.isUserRetweeted = false
                } else {
                    cell.reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon-green"), for: .normal)
                    cell.numRetwitteLabel.setButtonTitleColor(option: .green)
                    cell.tweet.isUserRetweeted = true
                    count += 1
                }
                cell.tweet.retweetCount = count
                
                cell.numRetwitteLabel.setTitle((count as Int).displayCountWithFormat(), for: .normal)
            }) { (task, error) in
                print(error)
                print("retweet: Error >>> \(error.localizedDescription)")
                cell.reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon-yellow"), for: .normal)
                cell.numRetwitteLabel.setButtonTitleColor(option: .yellow)
            }
        }
        alertController.addAction(retweetAction)
        
        if !isRetweeted {
            let quoteTweetAction = UIAlertAction(title: "Quote Tweet(Unavailable)", style: .default) { (action) in
                /// handle case of quote tweet
            }
            alertController.addAction(quoteTweetAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        cell.reTwitteButton.isEnabled = true
        cell.numRetwitteLabel.isEnabled = true
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func tweetCellFavoritedTapped(cell: TwitterTableViewCell, isFavorited: Bool) {
        var endpoint : String?
        
        cell.favoriteButton.isEnabled = false
        cell.numFavoriteLabel.isEnabled = false
        
        cell.favoriteButton.setImage(#imageLiteral(resourceName: "favorited-icon-blue"), for: .normal)
        cell.numFavoriteLabel.setButtonTitleColor(option: .blue)
        
        if cell.tweet.isUserFavorited! {
            endpoint = TwitterClient.APIScheme.FavoriteDestroyEndpoint
        } else {
            endpoint = TwitterClient.APIScheme.FavoriteCreateEndpoint
        }
        
        cell.client.post(endpoint!, parameters: ["id" : cell.tweet.id!], progress: nil, success: { (task, response) in
            print("retweet: success")
            
            var count = cell.tweet.favoriteCount!
            
            if cell.tweet.isUserFavorited! {
                cell.favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon"), for: .normal)
                cell.numFavoriteLabel.setButtonTitleColor(option: .gray)
                cell.tweet.isUserFavorited = false
                count -= 1
            } else {
                cell.favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon-red"), for: .normal)
                cell.numFavoriteLabel.setButtonTitleColor(option: .red)
                cell.tweet.isUserFavorited = true
                count += 1
            }
            
            cell.tweet.favoriteCount = count
            
            cell.numFavoriteLabel.setTitle((count as Int).displayCountWithFormat(), for: .normal)
        }) { (task, error) in
            print("retweet: Error >>> \(error.localizedDescription)")
            cell.favoriteButton.setImage(#imageLiteral(resourceName: "favorited-icon-yellow"), for: .normal)
            cell.numFavoriteLabel.setButtonTitleColor(option: .yellow)
        }
        
        cell.favoriteButton.isEnabled = true
        cell.numFavoriteLabel.isEnabled = true
    }
    
    func tweetCellMenuTapped(cell: TwitterTableViewCell, withId id: Int) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete Tweet", style: .destructive) { (action) in
            
            UIhelper.alertMessageWithAction("Delete Tweet", userMessage: "Are you sure you want to delete this Tweet?", left: "Cancel", right: "Delete", leftAction: nil, rightAction: { (action) in
                var endpoint = TwitterClient.APIScheme.TweetStatusDestroyEndpoint
                if let range = endpoint.range(of: ":id") {
                    endpoint = endpoint.replacingCharacters(in: range, with: "\(cell.tweet.id!)")
                }
                
                cell.client.post(endpoint, parameters: nil, progress: nil, success: { (task, response) in
                    print("Delete tweet: Success")
                    
                    self.tweets.remove(at: cell.index.row)
                    self.twitterTableView.deleteRows(at: [cell.index], with: .fade)
                    self.twitterTableView.reloadData()
                    
                }, failure: { (task, error) in
                    print("\(error.localizedDescription)")
                })
            }, sender: (UIApplication.shared.keyWindow?.rootViewController)!)
        }
        if cell.tweet.user?.id == UserModel.currentUser?.id {
            alertController.addAction(deleteAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    internal func getNewTweet(data: TweetModel) {
        // print(data.dictionary)
        requestData(parameters: ["since_id": since_id], type: 2)
    }
    
    internal func getPopoverImage(imageView: UIImageView) {
        popImage = imageView.image!
        performSegue(withIdentifier: "showImage", sender: self)
    }
    
    internal func removeCell(indexPath: IndexPath) {
        self.tweets.remove(at: indexPath.row)
        self.twitterTableView.deleteRows(at: [indexPath], with: .fade)
        self.twitterTableView.reloadData()
    }
    
    internal func updateNumber(tweet: TweetModel, indexPath: IndexPath) {
        self.tweets[indexPath.row] = tweet
        twitterTableView.reloadRows(at: [indexPath], with: .fade)
    }
}
