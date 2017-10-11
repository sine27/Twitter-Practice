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

// MARK: - UI Popover Presentation Controller Delegate

extension TwitterViewController: UIPopoverPresentationControllerDelegate {}

class TwitterViewController: UIViewController {
    
    var viewModel = TwitterTableViewModel()
    
    @IBOutlet weak var twitterTableView: UITableView!
    
    // UI Index
    let TABLE_FOOTER_HEIGHT: CGFloat = 0
    
    var uiHelper = UIhelper()
    
    var popImage = UIImage()

    // MARK: - IBAction
    
    @IBAction func logoutTapped(_ sender: Any) {
        UIhelper.alertMessage("Add Contacts", userMessage: "Unavailable", action: nil, sender: self)
    }
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIProperties()
        
        setupStartupUIAnimation()
        
        setupTableView()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.twitterTableView.es_startPullToRefresh()
        }
 
        // Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(TwitterViewController.onTimer), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // deselect cell when push back
        let selectedIndexPath = twitterTableView.indexPathForSelectedRow
        if selectedIndexPath != nil {
            twitterTableView.deselectRow(at: selectedIndexPath!, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTwitterDetail" {
            let vc = segue.destination as! TweetViewController

            if let index = twitterTableView.indexPathForSelectedRow {
                if let retweeted_status = viewModel.getTweetModel(at: index.row).retweeted_status {
                    vc.tweet = retweeted_status
                    vc.retweet = viewModel.getTweetModel(at: index.row)
                } else {
                    vc.tweet = viewModel.getTweetModel(at: index.row)
                }
                vc.indexPath = index
                vc.delegate = self
            }
        }
        
        // popover segue
        if segue.identifier == "popoverSegue" {
            let postViewController = segue.destination as! PostViewController
            postViewController.delegate = self
            postViewController.popoverPresentationController?.delegate = self
            postViewController.endpoint = viewModel.postEndpoint
            if viewModel.postEndpoint == 3 {
                postViewController.tweet = viewModel.postTweet
                postViewController.tweetOrg = viewModel.postTweetOrg
            }
        }
        
        // popover segue
        if segue.identifier == "showImage" {
            let previewViewController = segue.destination as! PreviewViewController
            previewViewController.delegate = self
            previewViewController.popoverPresentationController?.delegate = self
            previewViewController.image = popImage
        }
        if segue.identifier == "showProfile" {
            let vc = segue.destination as! ProfileViewController
            if viewModel.screenName != nil {
                vc.screenName = viewModel.screenName
            } else {
                vc.userProfile = viewModel.cellUser
            }
        }
    }
    
    // MARK: - UI Setup
    
    func setupStartupUIAnimation() {
        twitterTableView.alpha = 0
        uiHelper.stopActivityIndicator()
        uiHelper.activityIndicator(sender: self, style: UIActivityIndicatorViewStyle.gray)
    }
    
    func setupUIProperties() {
        automaticallyAdjustsScrollViewInsets = false
        
        // navigation bar logo
        let imageView = UIImageView(image: UIImage(named: "TwitterLogoBlue"))
        imageView.layer.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        
        // Navigation
        tabBarController?.tabBar.tintColor = UIhelper.UIColorOption.twitterBlue
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        
        // TabBar
        navigationController?.navigationBar.topItem?.title = ""
        
        viewModel.delegate = self
    }
    
    // MARK: - Helper
    
    func onTimer() {
        // Add code to be run periodically
        // requestData(parameters: parameters, type: 2)
        if viewModel.tweets.count != 0 {
            let offset = self.twitterTableView.contentOffset
            twitterTableView.reloadData()
            twitterTableView.layoutIfNeeded()
            twitterTableView.contentOffset = offset
        }
    }
    
    func do_table_refresh() {
        DispatchQueue.main.async {
            self.twitterTableView.reloadData()
            self.twitterTableView.es_stopLoadingMore()
            self.twitterTableView.es_stopPullToRefresh()
            if self.twitterTableView.alpha == 0 {
                UIView.animate(withDuration: 1.0, animations: {
                    self.twitterTableView.alpha = 1
                })
            }
        }
    }
}

// MARK: - Table View Delegate

extension TwitterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setupTableView() {
        // Do any additional setup after loading the view.
        twitterTableView.delegate = self
        twitterTableView.dataSource = self
        
        // auto adjust table cell height
        twitterTableView.rowHeight = UITableViewAutomaticDimension
        twitterTableView.estimatedRowHeight = 200
        
        twitterTableView.es_addPullToRefresh {
            self.viewModel.pullRefresh()
        }
        
        twitterTableView.es_addInfiniteScrolling {
            if self.viewModel.max_id == -1 {
                self.twitterTableView.es_noticeNoMoreData()
            }
            else { self.viewModel.loadMore() }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumbersOfTweets()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = viewModel.getTweetCellViewHeight(at: String(describing: indexPath)) {
            return CGFloat(height)
        }
      return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return TABLE_FOOTER_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // slide in cell
        //        cell.alpha = 0.0
        //        let transform = CATransform3DTranslate(CATransform3DIdentity, -250, 20, 0)
        //        cell.layer.transform = transform
        //
        //        UIView.animate(withDuration: 0.6) {
        //            cell.alpha = 1.0
        //            cell.layer.transform = CATransform3DIdentity
        //        }
        
        viewModel.setTweetCellViewHeight(at: String(describing: indexPath), with: Float(cell.frame.size.height))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "twitterCell") as! TweetTableViewCell
        let cell = Bundle.main.loadNibNamed("TweetTableViewCell", owner: self, options: nil)?.first as! TweetTableViewCell
        
        cell.viewModel = viewModel.viewModelForCell(at: indexPath.row)
        
        cell.index = indexPath
        
        cell.delegate = self
        
        cell.popDelegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showTwitterDetail", sender: self)
    }
}

// MARK: - Tweet Table View Cell Delegate

extension TwitterViewController: TweetTableViewCellDelegate {
    func tweetCellRetweetTapped(cell: TweetTableViewCell, isRetweeted: Bool) {
        var endpoint : String?
        // pop up menu
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        cell.reTwitteButton.isEnabled = false
        cell.numRetwitteLabel.isEnabled = false
        
        let tweetid = cell.viewModel.tweetForShow.id!
        var title = "Retweet"
        var style = UIAlertActionStyle.default
        
        if cell.viewModel.isTweetRetweeted() {
            title = "Undo Retweet"
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
                
                var count = cell.viewModel.tweetForShow.retweetCount ?? 0
                
                if cell.viewModel.isTweetRetweeted() {
                    cell.reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon"), for: .normal)
                    cell.numRetwitteLabel.setButtonTitleColor(option: .gray)
                    count -= 1
//                    if cell.viewModel.tweet == cell.viewModel.tweetForShow {
//                        self.viewModel.tweets.remove(at: cell.index.row)
//                        self.twitterTableView.reloadData()
//                    } else {
                        cell.viewModel.tweetForShow.isUserRetweeted = false
//                    }
                } else {
                    cell.reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon-green"), for: .normal)
                    cell.numRetwitteLabel.setButtonTitleColor(option: .green)
                    cell.viewModel.tweetForShow.isUserRetweeted = true
                    count += 1
                }
                cell.viewModel.tweetForShow.retweetCount = count
                
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
    
    func tweetCellFavoritedTapped(cell: TweetTableViewCell, isFavorited: Bool) {
        var endpoint : String?
        
        cell.favoriteButton.isEnabled = false
        cell.numFavoriteLabel.isEnabled = false
        
        cell.favoriteButton.setImage(#imageLiteral(resourceName: "favorited-icon-blue"), for: .normal)
        cell.numFavoriteLabel.setButtonTitleColor(option: .blue)
        
        if cell.viewModel.isTweetFavorited() {
            endpoint = TwitterClient.APIScheme.FavoriteDestroyEndpoint
        } else {
            endpoint = TwitterClient.APIScheme.FavoriteCreateEndpoint
        }
        
        cell.client.post(endpoint!, parameters: ["id" : cell.viewModel.tweetForShow.id!], progress: nil, success: { (task, response) in
            print("retweet: success")
            
            var count = cell.viewModel.tweetForShow.favoriteCount ?? 0
            
            if cell.viewModel.isTweetFavorited() {
                cell.favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon"), for: .normal)
                cell.numFavoriteLabel.setButtonTitleColor(option: .gray)
                cell.viewModel.tweetForShow.isUserFavorited = false
                count -= 1
            } else {
                cell.favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon-red"), for: .normal)
                cell.numFavoriteLabel.setButtonTitleColor(option: .red)
                cell.viewModel.tweetForShow.isUserFavorited = true
                count += 1
            }
            
            cell.viewModel.tweetForShow.favoriteCount = count
            
            cell.numFavoriteLabel.setTitle((count as Int).displayCountWithFormat(), for: .normal)
        }) { (task, error) in
            print("retweet: Error >>> \(error.localizedDescription)")
            cell.favoriteButton.setImage(#imageLiteral(resourceName: "favorited-icon-yellow"), for: .normal)
            cell.numFavoriteLabel.setButtonTitleColor(option: .yellow)
        }
        
        cell.favoriteButton.isEnabled = true
        cell.numFavoriteLabel.isEnabled = true
    }
    
    func tweetCellMenuTapped(cell: TweetTableViewCell, withId id: Int) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete Tweet", style: .destructive) { (action) in
            
            UIhelper.alertMessageWithAction("Delete Tweet", userMessage: "Are you sure you want to delete this Tweet?", left: "Cancel", right: "Delete", leftAction: nil, rightAction: { (action) in
                var endpoint = TwitterClient.APIScheme.TweetStatusDestroyEndpoint
                if let range = endpoint.range(of: ":id") {
                    endpoint = endpoint.replacingCharacters(in: range, with: "\(cell.viewModel.tweetForShow.id!)")
                }
                
                cell.client.post(endpoint, parameters: nil, progress: nil, success: { (task, response) in
                    print("Delete tweet: Success")
                    
                    self.viewModel.tweets.remove(at: cell.index.row)
                    self.twitterTableView.deleteRows(at: [cell.index], with: .fade)
                    self.twitterTableView.reloadData()
                    
                }, failure: { (task, error) in
                    print("\(error.localizedDescription)")
                })
            }, sender: self)
        }
        if cell.viewModel.tweetForShow.user?.id == UserModel.currentUser?.id {
            alertController.addAction(deleteAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func tweetCellReplyTapped(cell: TweetTableViewCell, withId: Int) {
        print("Reply Tapped")
        viewModel.postEndpoint = 3
        viewModel.postTweet = cell.viewModel.tweetForShow
        if cell.viewModel.tweet != cell.viewModel.tweetForShow {
            viewModel.postTweetOrg = cell.viewModel.tweet
        }
        performSegue(withIdentifier: "popoverSegue", sender: self)
    }
    
    internal func tweetCellMentionTapped(with screenName: String) {
        viewModel.screenName = screenName
        performSegue(withIdentifier: "showProfile", sender: self)
    }
    
    internal func tweetCellUserProfileImageTapped(cell: TweetTableViewCell, forTwitterUser user: UserModel?) {
        viewModel.cellUser = user
        performSegue(withIdentifier: "showProfile", sender: self)
    }
}

// MARK: - Tweet Table View Delegate

extension TwitterViewController: TweetTableViewDelegate {
    internal func getNewTweet(data: TweetModel?) {
        print("PostViewController Back...")
        viewModel.postEndpoint = 0
        viewModel.postTweet = nil
        viewModel.postTweetOrg = nil
        if data != nil {
            viewModel.getTweets(parameters: ["since_id": viewModel.since_id], type: .getNew)
        }
    }
    
    internal func getPopoverImage(imageView: UIImageView) {
        popImage = imageView.image!
        performSegue(withIdentifier: "showImage", sender: self)
    }
}

// MARK: - Update Cell From Table Delegate

extension TwitterViewController: UpdateCellFromTableDelegate {
    internal func removeCell(indexPath: IndexPath) {
        viewModel.tweets.remove(at: indexPath.row)
        self.twitterTableView.deleteRows(at: [indexPath], with: .fade)
        self.twitterTableView.reloadData()
    }
    
    internal func updateNumber(tweet: TweetModel, indexPath: IndexPath) {
        viewModel.tweets[indexPath.row] = tweet
        twitterTableView.reloadRows(at: [indexPath], with: .fade)
    }
}

extension TwitterViewController: ViewModelDelegate {
    func presentAltertWithAction(message: String) {
        twitterTableView.es_stopPullToRefresh()
        twitterTableView.es_stopLoadingMore()
        OtherHelper.alertWithAction("Error", message: message, numActions: 1, actionTitles: ["OK"], actionStyles: [.default], actions: [nil], sender: self)
    }
    
    func reloadTable(section: Int?, row: Int?, loadType: LoadType?) {
        DispatchQueue.main.async {
            self.uiHelper.stopActivityIndicator()
        }
        if section != nil {
            if row != nil {
                return twitterTableView.reloadRows(at: [IndexPath(row: row!, section: section!)], with: .none)
            }
            return twitterTableView.reloadSections([section!], with: .none)
        }
        if loadType != nil {
            switch loadType! {
            case .loadMore:
                do_table_refresh()
             case .pullRefresh:
                do_table_refresh()
            case .getNew:
                let offset = self.twitterTableView.contentOffset
                //self.twitterTableView.reloadData()
                do_table_refresh()
                twitterTableView.contentOffset = offset
            }
        } else {
            do_table_refresh()
        }
    }
}
