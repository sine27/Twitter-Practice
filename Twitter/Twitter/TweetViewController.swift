//
//  TweetViewController.swift
//  Twitter
//
//  Created by Shayin Feng on 2/22/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import ActiveLabel

class TweetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, PreviewViewDelegate {
    
    @IBOutlet weak var tweetTableView: UITableView!
    
    var tweet: TweetModel?
    
    let uiHelper = UIhelper()
    
    var popImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()

         print(tweet?.dictionary ?? "{}")
        // Do any additional setup after loading the view.
        tweetTableView.delegate = self
        tweetTableView.dataSource = self
        
        tweetTableView.rowHeight = UITableViewAutomaticDimension
        tweetTableView.estimatedRowHeight = 60
        
        tweetTableView.tableFooterView = UIView()
        tweetTableView.tableFooterView?.backgroundColor = UIColor.gray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationController!.navigationBar.topItem?.title = ""
        self.navigationItem.backBarButtonItem?.tintColor = UIhelper.UIColorOption.twitterBlue
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        uiHelper.removeTwitterFooter()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell0") as! TweetDetailTableViewCell
            cell.tweet = self.tweet
            
            /// in order to get image tapped gesture
            cell.delegate = self
            
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1") as! TweetCountTableViewCell
            cell.tweet = self.tweet
            return cell
        }
        else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2") as! TweetButtonTableViewCell
            cell.tweet = self.tweet
            
            let diff = tweetTableView.frame.height - tweetTableView.contentSize.height
            // print("didEndEditingRowAt: \(diff)")
            if diff >= 75 {
                let footerPositionY = tweetTableView.frame.height - diff + 70
                uiHelper.showTwitterFooter(sender: self, positionX: self.view.center.x - 25, positionY: footerPositionY)
            }
            
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
    
    // show twitter logo at the end of the table
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        uiHelper.removeTwitterFooter()
        let diff = self.tweetTableView.frame.height - scrollView.contentSize.height + scrollView.contentOffset.y
        // print("scrollViewDidScroll: \(diff)")
        if diff >= 75 {
            let footerPositionY = tweetTableView.frame.height - diff + 75
            uiHelper.showTwitterFooter(sender: self, positionX: self.view.center.x - 25, positionY: footerPositionY)
        } else {
            uiHelper.removeTwitterFooter()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // popover segue
        if segue.identifier == "toReply" {
            let popoverViewController = segue.destination as! PostViewController
            // popoverViewController.delegate = self
            // popoverViewController.popoverPresentationController?.delegate = self
            popoverViewController.endpoint = 1
        }
        if segue.identifier == "detailShowImage" {
            let popoverViewController = segue.destination as! PreviewViewController
             popoverViewController.delegate = self
             popoverViewController.popoverPresentationController?.delegate = self
            popoverViewController.image = self.popImage
        }
    }

    func getPopoverImage(imageView: UIImageView) {
        print("Pop over!")
        popImage = imageView.image!
        performSegue(withIdentifier: "detailShowImage", sender: self)
    }
    
}
