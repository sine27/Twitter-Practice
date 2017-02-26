//
//  TweetViewController.swift
//  Twitter
//
//  Created by Shayin Feng on 2/22/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import ActiveLabel

class TweetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tweetTableView: UITableView!
    
    var tweet: TweetModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        print(tweet?.dictionary ?? "{}")
        // Do any additional setup after loading the view.
        tweetTableView.delegate = self
        tweetTableView.dataSource = self
        
        tweetTableView.rowHeight = UITableViewAutomaticDimension
        tweetTableView.estimatedRowHeight = 60

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell0") as! TweetDetailTableViewCell
            cell.layoutMargins = UIEdgeInsets.init(top: 8, left: 8, bottom: 0, right: 0)
            cell.tweet = self.tweet
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1") as! TweetCountTableViewCell
            cell.layoutMargins = UIEdgeInsets.init(top: 8, left: 8, bottom: 0, right: 0)
            cell.tweet = self.tweet
            return cell
        }
        else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2") as! TweetButtonTableViewCell
            cell.layoutMargins = UIEdgeInsets.zero
            cell.tweet = self.tweet
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell") as! TweetReviewTableViewCell
            cell.layoutMargins = UIEdgeInsets.zero
            cell.tweet = self.tweet
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // popover segue
        if segue.identifier == "toReply" {
            let popoverViewController = segue.destination as! PostViewController
            // popoverViewController.delegate = self
            // popoverViewController.popoverPresentationController?.delegate = self
            popoverViewController.endpoint = 0
        }
//        if segue.identifier == "detailShowImage" {
//            let popoverViewController = segue.destination as! PostViewController
//            // popoverViewController.delegate = self
//            // popoverViewController.popoverPresentationController?.delegate = self
//            popoverViewController.endpoint = 0
//        }
    }

}
