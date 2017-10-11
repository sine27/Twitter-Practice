//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Shayin Feng on 2/21/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
let distance_W_LabelHeader:CGFloat = 35.0 // The distance between the bottom of the Header and the top

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate, TweetTableViewCellDelegate, TweetTableViewDelegate, UpdateCellFromTableDelegate {
    
    var viewModel = TwitterTableViewModel()

    @IBOutlet weak var followingButton: UIButton!
    
    @IBOutlet weak var followerButton: UIButton!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var userTweetsTableView: UITableView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var profileView: UIView!
    
    @IBOutlet weak var avatarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var avatarLeading: NSLayoutConstraint!
    
    @IBOutlet weak var avatarToTop: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var headerImageHeight: NSLayoutConstraint!

    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var nameBarLabel: UILabel!
    
    @IBOutlet weak var numStatusLabel: UILabel!
    
    var avatarHeightCopy: CGFloat?
    
    var avatarLeadingCopy: CGFloat?
    
    var avatarToTopCopy: CGFloat?
    
    var headerImageHeightCopy: CGFloat?
    
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
    
    let screenHeight = UIScreen.main.bounds.height
    
    let screenWidth = UIScreen.main.bounds.width

    var profileViewHeight: CGFloat?
    
    var userProfile: UserModel?
    
    var screenName: String?
    
    var max_id = -1
    
    var since_id = -1
    
    var tweets: [TweetModel] = [] {
        didSet {
            viewModel.tweets = tweets
        }
    }
    
    var uiHelper = UIhelper()
    
    var parameters: Any?
    
    var heightAtIndexPath = NSMutableDictionary()
    
    var popImage = UIImage()
    
    var endpoint = TwitterClient.APIScheme.UserTimelineEndpoint

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTweetsTableView.dataSource = self
        userTweetsTableView.delegate = self
        userTweetsTableView.rowHeight = UITableViewAutomaticDimension
        userTweetsTableView.estimatedRowHeight = 80
        userTweetsTableView.alpha = 0.0
        
        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 8
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.layer.borderWidth = 3
        avatarHeightCopy = avatarHeight.constant
        avatarLeadingCopy = avatarLeading.constant
        avatarToTopCopy = avatarToTop.constant
        headerImageHeightCopy = headerImageHeight.constant
        descriptionHeight.isActive = true
        
        blurView.frame = backgroundView.bounds
        blurView.alpha = 0.0
        backgroundImageView.addSubview(blurView)
        
        nameBarLabel.alpha = 0.0
        numStatusLabel.alpha = 0.0
        
        userTweetsTableView.scrollIndicatorInsets = UIEdgeInsets(top: profileView.frame.height + 50, left: 0, bottom: 0, right: 0)
        
        profileViewHeight = profileView.frame.height
        
        if screenName != nil {
            parameters = ["screen_name": screenName!]
        } else if userProfile == nil {
            userProfile = UserModel.currentUser
            parameters = nil
        } else {
            parameters = ["screen_name": userProfile!.screen_name]
        }
        
        setupProfile ()
        
        userTweetsTableView.es_addPullToRefresh {
            if self.since_id == -1 {

            } else {
                self.parameters = ["screen_name": self.userProfile!.screen_name ?? "", "since_id": self.since_id, "count": 5]
            }
            self.requestData(endpoint: self.endpoint, parameters: self.parameters, type: 0)
            
            var param = self.parameters
            if param == nil {
                param = ["screen_name": self.userProfile!.screen_name ?? ""]
            }
            self.requestData(endpoint: TwitterClient.APIScheme.UserShowEndpoint, parameters: self.parameters, type: 4)
        }
        
        userTweetsTableView.es_addInfiniteScrolling {
            if self.max_id == -1 {
                self.userTweetsTableView.es_noticeNoMoreData()
            } else {
                self.parameters = ["screen_name": self.userProfile!.screen_name ?? "", "max_id": self.max_id, "count": 10]
                self.requestData(endpoint: self.endpoint, parameters: self.parameters, type: 1)
            }
        }
        
        requestData(endpoint: endpoint, parameters: parameters, type: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //profileView.translatesAutoresizingMaskIntoConstraints = false
        // deselect cell when push back
        let selectedIndexPath = userTweetsTableView.indexPathForSelectedRow
        if selectedIndexPath != nil {
            userTweetsTableView.deselectRow(at: selectedIndexPath!, animated: false)
        }
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.tintColor = UIhelper.UIColorOption.twitterBlue
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // Transparent NavigationBar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        // Sets shadow (line below the bar) to a blank image
        self.navigationController?.navigationBar.shadowImage = UIImage()
//        // Sets the translucent background color
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        self.navigationController?.navigationBar.isTranslucent = true

        sizeHeaderToFit()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0.6) {
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.tintColor = UIhelper.UIColorOption.twitterBlue
        }
    }
    
    func setupProfile () {
        
        if userProfile == nil, screenName != nil {
            requestData(endpoint: TwitterClient.APIScheme.UserShowOneEndpoint, parameters: parameters, type: 5)
            return
        }

        if let avatarURL = userProfile?.profile_image_url_https {
            avatarImageView.setImageWith(URLRequest(url: avatarURL), placeholderImage: #imageLiteral(resourceName: "noImage"), success: { (request, response, image) in
                self.avatarImageView.alpha = 0.0
                self.avatarImageView.image = image
                UIView.animate(withDuration: 0.8, animations: {
                    self.avatarImageView.alpha = 1.0
                })
            }, failure: { (request, response, error) in
                if self.userProfile?.profile_image_url != nil {
                    self.avatarImageView.setImageWith((self.userProfile?.profile_image_url)!)
                }
            })
        }

        if let nameString = userProfile?.name {
            nameBarLabel.text = userProfile!.name
            if let verified = userProfile?.verified {
                if verified == true {
                    let attachment = NSTextAttachment()
                    attachment.image = #imageLiteral(resourceName: "verified-account")
                    // attachment.image = UIImage(cgImage: (attachment.image?.cgImage)!, scale: 6, orientation: .up)
                    attachment.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)
                    let attachmentString = NSAttributedString(attachment: attachment)
                    let myString = NSMutableAttributedString(string: "\(nameString) ")
                    myString.append(attachmentString)
                    nameLabel.attributedText = myString
                } else {
                    nameLabel.text = nameString
                }
            }
        } else {
            nameLabel.text = ""
        }
        
        if let screenNameString = userProfile?.screen_name {
            screenNameLabel.text = screenNameString
        } else {
            screenNameLabel.text = ""
        }
        
        if let description = userProfile?.use_description, description != "" {
            let finalString = NSMutableAttributedString(string: "\(description)")
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 3
            finalString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, finalString.length))
            
            if let location = userProfile?.location, location != "" {
                let locationString = NSMutableAttributedString(string: "\n\n")
                let attachment = NSTextAttachment()
                attachment.image = #imageLiteral(resourceName: "location-icon")
                attachment.bounds = CGRect(x: 0, y: -5, width: 24, height: 24)
                let attachmentString = NSAttributedString(attachment: attachment)
                locationString.append(attachmentString)
                locationString.append(NSMutableAttributedString(string: "\(location)" ))
                locationString.addAttribute(NSForegroundColorAttributeName, value:  UIhelper.UIColorOption.twitterBlue, range: NSRange(location: 0, length: locationString.length))
                
                paragraphStyle.lineSpacing = 0
                locationString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, locationString.length))
                
                finalString.append(locationString)
            }
            
            descriptionLabel.attributedText = finalString
        } else {
            descriptionHeight.isActive = false
            descriptionLabel.heightAnchor.constraint(equalToConstant: -5)
        }
        
        if let statuses_count = userProfile?.statuses_count {
            numStatusLabel.text = "\(statuses_count) Tweets"
        } else {
            numStatusLabel.text = "0 Tweets"
        }
        
        parameters = ["screen_name": userProfile!.screen_name]
        requestData(endpoint: TwitterClient.APIScheme.UserBannerEndpoint, parameters: parameters, type: 3)
        
        if let followingCount = userProfile?.friend_count {
            
            let attributeNum = [ NSFontAttributeName: UIFont.systemFont(ofSize: 13, weight: UIFontWeightSemibold) ]
            let numString = NSMutableAttributedString(string: "\(followingCount)", attributes: attributeNum )
            
            var range = NSRange(location: 0, length: numString.length)
            numString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: range)
            
            let attributeText = [ NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular) ]
            let textString = NSMutableAttributedString(string: " FOLLOWING", attributes: attributeText )
            numString.append(textString)
            
            range = NSRange(location: numString.length - textString.length, length: textString.length)
            numString.addAttribute(NSForegroundColorAttributeName, value: UIhelper.UIColorOption.twitterGray, range: range)
            
            followingButton.setAttributedTitle(numString, for: .normal)
        }
        
        if let followerCount = userProfile?.followers_count {
            let attributeNum = [ NSFontAttributeName: UIFont.systemFont(ofSize: 13, weight: UIFontWeightSemibold) ]
            let numString = NSMutableAttributedString(string: "\(followerCount)", attributes: attributeNum )
            
            var range = NSRange(location: 0, length: numString.length)
            numString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: range)
            
            let attributeText = [ NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular) ]
            let textString = NSMutableAttributedString(string: " FOLLOWERS", attributes: attributeText )
            numString.append(textString)
            
            range = NSRange(location: numString.length - textString.length, length: textString.length)
            numString.addAttribute(NSForegroundColorAttributeName, value: UIhelper.UIColorOption.twitterGray, range: range)
            
            followerButton.setAttributedTitle(numString, for: .normal)
        }

    }

    func sizeHeaderToFit() {
        
        profileView.setNeedsLayout()
        profileView.layoutIfNeeded()
        
        let height = profileView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = profileView.frame
        frame.size.height = height
        profileView.frame = frame
        
        userTweetsTableView.tableHeaderView = profileView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestData (endpoint: String, parameters: Any?, type: Int) {
        
        if let client = TwitterClient.sharedInstance {
            client.get(endpoint, parameters: parameters, progress: nil, success: { (task, response) in
                
                print("Profile: Success type \(type)")
                
                if type == 5 {
                    let dictionary = response as! NSDictionary
                    self.userProfile = UserModel(dictionary: dictionary)
                    self.setupProfile()
                    return 
                }
                
                if type != 3 {
                    let dictionary = response as! [NSDictionary]
                    var tweetsTmp: [TweetModel] = []
                    for tweet in dictionary {
                        tweetsTmp.append(TweetModel(dictionary: tweet))
                    }
                    // refresh
                    if type == 0 {
                        self.tweets = tweetsTmp + self.tweets
                        
                        self.since_id = self.tweets[0].id!
                        self.max_id = self.tweets[self.tweets.count - 1].id!
                        
                        self.userTweetsTableView.reloadData()
                        self.userTweetsTableView.layoutIfNeeded()
                        self.userTweetsTableView.beginUpdates()
                        self.userTweetsTableView.endUpdates()
                        
                        UIView.animate(withDuration: 0.6, animations: {
                            self.userTweetsTableView.alpha = 1.0
                        })
                        self.userTweetsTableView.es_stopPullToRefresh()
                    }
                    
                    // load more
                    else if type == 1 {
                        
                        tweetsTmp.remove(at: 0)
                        
                        if tweetsTmp.count <= 0 {
                            return self.userTweetsTableView.es_removeRefreshFooter()
                        }
                        
                        self.tweets += tweetsTmp
                        
                        self.max_id = self.tweets[self.tweets.count - 1].id!
                        self.userTweetsTableView.reloadData()
                        self.userTweetsTableView.layoutIfNeeded()
                        self.userTweetsTableView.beginUpdates()
                        self.userTweetsTableView.endUpdates()
                        self.userTweetsTableView.es_stopLoadingMore()
                    }
                        
                    // load new
                    else if type == 2 {
                        self.tweets = tweetsTmp + self.tweets
                        
                        self.since_id = self.tweets[0].id!
                        self.max_id = self.tweets[self.tweets.count - 1].id!
                        
                        let offset = self.userTweetsTableView.contentOffset
                        self.userTweetsTableView.reloadData()
                        self.userTweetsTableView.layoutIfNeeded()
                        self.userTweetsTableView.beginUpdates()
                        self.userTweetsTableView.endUpdates()
                        self.userTweetsTableView.contentOffset = offset
                    }
                }
                else {
                    let dictionary = response as! NSDictionary
                    print(dictionary)
                    // type 3 banner
                    if type == 3 {
                        let sizes = dictionary["sizes"] as! NSDictionary
                        let large = sizes["1500x500"] as! NSDictionary
                        let urlString = large["url"] as! String
                        
                        self.backgroundImageView.setImageWith(URLRequest(url: URL(string: urlString)!), placeholderImage: nil, success: { (request, response, image) in
                            self.backgroundImageView.alpha = 0.0
                            self.backgroundImageView.image = image
                            UIView.animate(withDuration: 0.8, animations: {
                                self.backgroundImageView.alpha = 1.0
                            })
                        }, failure: { (request, response, error) in
                            self.backgroundImageView.image = nil
                            self.backgroundView.backgroundColor = UIhelper.UIColorOption.twitterBlue
                        })
                    }
                }
                
                self.uiHelper.stopActivityIndicator()
                UIView.animate(withDuration: 1.0, animations: {
                    self.userTweetsTableView.alpha = 1
                })
            }, failure: { (task, error) in
                if type == 3 {
                    self.backgroundImageView.image = nil
                    self.backgroundView.backgroundColor = UIhelper.UIColorOption.twitterBlue
                } else {
                    //UIhelper.alertMessage("Request type \(type)", userMessage: error.localizedDescription, action: nil, sender: self)
                    print("FetchTimelineData: Error >>> \(error.localizedDescription)")
                    self.uiHelper.stopActivityIndicator()
                    
                    if type == 0 {
                        self.userTweetsTableView.es_stopPullToRefresh()
                    } else if type == 1 {
                        self.userTweetsTableView.es_stopLoadingMore()
                    }
                }
            })
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = Bundle.main.loadNibNamed("TweetTableViewCell", owner: self, options: nil)?.first as! TweetTableViewCell
        
        cell.viewModel = viewModel.viewModelForCell(at: indexPath.row)
        
        cell.index = indexPath
        
        cell.delegate = self
        
        cell.popDelegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = Bundle.main.loadNibNamed("ProfileHeaderTableViewCell", owner: self, options: nil)?.first as! ProfileHeaderTableViewCell
        return headerCell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "profileToDetail", sender: self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let scrollToTop = profileView.frame.height + 50
        let difference = scrollToTop - offset
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
//        print(offset)
        
        if difference >= 0 {
            userTweetsTableView.scrollIndicatorInsets = UIEdgeInsets(top: difference, left: 0, bottom: 0, right: 0)
        }
        
        if offset < 0 {
            let headerScaleFactor:CGFloat = -(offset) / backgroundView.bounds.height
            let headerSizevariation = ((backgroundView.bounds.height * (1.0 + headerScaleFactor)) - backgroundView.bounds.height)/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            backgroundImageView.subviews[0].alpha = min (0.8, (0 - offset)/20)
            
            backgroundView.layer.transform = headerTransform
        }
            
        else {
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            
            backgroundImageView.subviews[0].alpha = min (0.8, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            
            var labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
            nameBarLabel.layer.transform = labelTransform
            labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
            numStatusLabel.layer.transform = labelTransform
            
            if offset > 98 {
                nameBarLabel.alpha = min (1.0, (offset - 98)/10)
                numStatusLabel.alpha = min (1.0, (offset - 98)/10)
            }
            
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImageView.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((avatarImageView.bounds.height * (1.0 + avatarScaleFactor)) - avatarImageView.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                if avatarImageView.layer.zPosition < backgroundView.layer.zPosition{
                    backgroundView.layer.zPosition = 0
                }
                
            }
            else {
                if avatarImageView.layer.zPosition >= backgroundView.layer.zPosition{
                    backgroundView.layer.zPosition = 2
                }
            }
        }
        
        backgroundView.layer.transform = headerTransform
        avatarImageView.layer.transform = avatarTransform
    }

    @IBAction func SettingButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Sign out", style: .default) { (action) in
            
            UIhelper.alertMessageWithAction("Log Out", userMessage: "Are you sure to logout?", left: "Cancel", right: "Logout", leftAction: nil, rightAction: { (action) in
                if let client = TwitterClient.sharedInstance {
                    client.logout()
                }
            }, sender: self)
        }
        
        if userProfile?.id == UserModel.currentUser?.id {
            alertController.addAction(deleteAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func tweetCellRetweetTapped(cell: TweetTableViewCell, isRetweeted: Bool) {
        var endpoint : String?
        // pop up menu
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        cell.reTwitteButton.isEnabled = false
        cell.numRetwitteLabel.isEnabled = false
        
        let tweetid = cell.viewModel.tweetForShow.user!.id!
        var title = "Retweet"
        var style = UIAlertActionStyle.default
        
        if cell.viewModel.isTweetRetweeted() {
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
                
                var count = cell.viewModel.tweetForShow.retweetCount ?? 0
                
                if cell.viewModel.isTweetRetweeted() {
                    cell.reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon"), for: .normal)
                    cell.numRetwitteLabel.setButtonTitleColor(option: .gray)
                    count -= 1
                    cell.viewModel.tweetForShow.isUserRetweeted = false
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
                    self.userTweetsTableView.deleteRows(at: [cell.index], with: .fade)
                    self.userTweetsTableView.reloadData()
                    
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
        let vc = storyboard?.instantiateViewController(withIdentifier: "profileViewController") as! ProfileViewController
        vc.screenName = screenName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    internal func tweetCellUserProfileImageTapped(cell: TweetTableViewCell, forTwitterUser user: UserModel?) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "profileViewController") as! ProfileViewController
        vc.userProfile = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    internal func getNewTweet(data: TweetModel?) {
        // print(data.dictionary)
        if data != nil {
            requestData(endpoint: TwitterClient.APIScheme.UserTimelineEndpoint, parameters: ["since_id": since_id], type: 2)
        }
    }
    
    internal func getPopoverImage(imageView: UIImageView) {
        popImage = imageView.image!
        performSegue(withIdentifier: "profileToImage", sender: self)
    }
    
    internal func removeCell(indexPath: IndexPath) {
        self.tweets.remove(at: indexPath.row)
        self.userTweetsTableView.deleteRows(at: [indexPath], with: .fade)
        self.userTweetsTableView.reloadData()
    }
    
    internal func updateNumber(tweet: TweetModel, indexPath: IndexPath) {
        self.tweets[indexPath.row] = tweet
        userTweetsTableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileToDetail" {
            let vc = segue.destination as! TweetViewController
            
            let indexPath = userTweetsTableView.indexPathForSelectedRow
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
        if segue.identifier == "profileToEdit" {
            let popoverViewController = segue.destination as! PostViewController
            popoverViewController.delegate = self
            popoverViewController.popoverPresentationController?.delegate = self
            if userProfile?.id == UserModel.currentUser?.id {
                popoverViewController.endpoint = 0
            } else {
                popoverViewController.endpoint = 2
            }
            
        }
        // popover segue
        if segue.identifier == "profileToImage" {
            let popoverViewController = segue.destination as! PreviewViewController
            popoverViewController.delegate = self
            popoverViewController.popoverPresentationController?.delegate = self
            popoverViewController.image = popImage
        }
    }

}

extension ProfileViewController: ViewModelDelegate {
    func presentAltertWithAction(message: String) {
        userTweetsTableView.es_stopPullToRefresh()
        userTweetsTableView.es_stopLoadingMore()
        OtherHelper.alertWithAction("Error", message: message, numActions: 1, actionTitles: ["OK"], actionStyles: [.default], actions: [nil], sender: self)
    }
    
    func reloadTable(section: Int?, row: Int?, loadType: LoadType?) {
        if section != nil {
            if row != nil {
                return userTweetsTableView.reloadRows(at: [IndexPath(row: row!, section: section!)], with: .none)
            }
            return userTweetsTableView.reloadSections([section!], with: .none)
        }
        if loadType != nil {
            switch loadType! {
            case .loadMore:
                userTweetsTableView.reloadData()
                self.userTweetsTableView.es_stopPullToRefresh()
            case .pullRefresh:
                userTweetsTableView.reloadData()
                self.userTweetsTableView.es_stopLoadingMore()
            case .getNew:
                let offset = self.userTweetsTableView.contentOffset
                //self.twitterTableView.reloadData()
                userTweetsTableView.reloadData()
                userTweetsTableView.contentOffset = offset
            }
        } else {
            userTweetsTableView.reloadData()
        }
    }
}
