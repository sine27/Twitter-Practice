//
//  TwitterViewController.swift
//  Twitter
//
//  Created by Shayin Feng on 2/21/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import ESPullToRefresh

class TwitterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var twitterTableView: UITableView!
    
    var tweets: [NSDictionary] = []
    
    var uiHelper = UIhelper()
    

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
            self.requestData()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.twitterTableView.es_startPullToRefresh()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // deselect cell when push back
        let selectedIndexPath = twitterTableView.indexPathForSelectedRow
        if selectedIndexPath != nil {
            twitterTableView.deselectRow(at: selectedIndexPath!, animated: false)
        }
    }
    
    func requestData () {
        if let client = TwitterClient.sharedInstance {
            client.fetchTimelineData(endpoint: TwitterClient.APIScheme.HomeTimelineEndpoint, parameters: nil) { (dictionary, error) in
                if let error = error {
                    print("FetchTimelineData: Error >>> \(error.localizedDescription)")
                    self.uiHelper.stopActivityIndicator()
                    self.twitterTableView.es_stopPullToRefresh()
                }
                else if let dictionary = dictionary {
                    self.tweets = dictionary
                    
                    self.uiHelper.stopActivityIndicator()
                    UIView.animate(withDuration: 1.0, animations: {
                        self.twitterTableView.alpha = 1
                    })
                    
                    self.twitterTableView.reloadData()
                    self.twitterTableView.es_stopPullToRefresh()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "twitterCell") as! TwitterTableViewCell
        
        let tweet = tweets[indexPath.row]
        
        let tweetmodel = TweetModel(dictionary: tweet)
        
        if tweetmodel.isUserRetweeted! == true {
            cell.reTwitteButton.imageView?.image = #imageLiteral(resourceName: "retweet-icon-green")
        } else {
            cell.reTwitteButton.imageView?.image = #imageLiteral(resourceName: "retweet-icon")
        }
        
        if tweetmodel.isUserFavorited! == true {
            cell.favoriteButton.imageView?.image = #imageLiteral(resourceName: "favor-icon-red")
        } else {
            cell.favoriteButton.imageView?.image = #imageLiteral(resourceName: "favor-icon")
        }
        
        if let timeCreated = tweetmodel.createdAt {
            let now = Date()
            let difference = now.offset(from: timeCreated)
            cell.timeCreateLabel.text = difference
        } else {
            cell.timeCreateLabel.text = "unkown"
        }
        
        if let retweeted_status = tweetmodel.retweeted_status {
            cell.userName = tweetmodel.user?.name
            cell.tweet = retweeted_status
        } else {
            cell.tweet = tweetmodel
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logoutTapped(_ sender: Any) {
        
        let myAlert = UIAlertController(title: "Log Out", message: "Are you sure to logout?", preferredStyle: UIAlertControllerStyle.alert)
        
        myAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            myAlert .dismiss(animated: true, completion: nil)
        }))
        
        myAlert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (action: UIAlertAction!) in
            if let client = TwitterClient.sharedInstance {
                client.logout()
            }
        }))
        present(myAlert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTwitterDetail" {
            let vc = segue.destination as! TweetViewController
            
            let indexPath = twitterTableView.indexPathForSelectedRow
            if let index = indexPath {
                print(self.tweets[index.row])
                vc.tweet = TweetModel(dictionary: self.tweets[index.row])
            }
        }

    }
}
