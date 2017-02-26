//
//  TwitterTableViewCell.swift
//  Twitter
//
//  Created by Shayin Feng on 2/21/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import AFNetworking
import ActiveLabel

class TwitterTableViewCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var userAvatar: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var timeCreateLabel: UILabel!
    
    @IBOutlet weak var menuButton: UIButton!
    
    // @IBOutlet weak var contentLabel: UITextView!
    @IBOutlet weak var contentLabel: ActiveLabel!
    
    @IBOutlet weak var replyButton: UIButton!
    
    @IBOutlet weak var numReplyLabel: UIButton!
    
    @IBOutlet weak var reTwitteButton: UIButton!
    
    @IBOutlet weak var numRetwitteLabel: UIButton!

    @IBOutlet weak var favoriteButton: UIButton!

    @IBOutlet weak var numFavoriteLabel: UIButton!
    
    @IBOutlet weak var messageButton: UIButton!
    
    //@IBOutlet weak var contentToTop: NSLayoutConstraint!
    
    @IBOutlet weak var contentImage: UIImageView!
    
    @IBOutlet weak var contentImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var stackToContentImage: NSLayoutConstraint!
    
    @IBOutlet weak var retweetLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var retweetStack: UIStackView!
    
    @IBOutlet weak var retweetLabel: UILabel!
    
    @IBOutlet weak var avatarToRetweeted: NSLayoutConstraint!
    
    var tapGesture = UITapGestureRecognizer()
    
    var delegate: SubviewViewControllerDelegate?
    
    let client = TwitterClient.sharedInstance!
    
    var index: IndexPath!
    
    var tweet: TweetModel! {
        didSet {
            updateUIWithTweetDetails()
        }
    }
    
    var userTweetForRetweet: TweetModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userAvatar.layer.masksToBounds = true
        userAvatar.layer.cornerRadius = 5
        userAvatar.image = #imageLiteral(resourceName: "noImage")
        contentImage.layer.masksToBounds = true
        contentImage.layer.cornerRadius = 5
        reTwitteButton.isEnabled = true
        numRetwitteLabel.isEnabled = true
        favoriteButton.isEnabled = true
        numFavoriteLabel.isEnabled = true
        
        self.layoutIfNeeded()

        contentLabel.customize { contentLabel in
            
            contentLabel.handleHashtagTap { hashtag in
                print("Success. You just tapped the \(hashtag) hashtag")
            }
            contentLabel.handleURLTap { (url) in
                print("Success. You just tapped the \(url) url")
            }
            contentLabel.handleMentionTap { (mention) in
                print("Success. You just tapped the \(mention) mention")
            }
        }
        setupCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        userAvatar.image = #imageLiteral(resourceName: "noImage")
        reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon"), for: .normal)
        favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon"), for: .normal)
        numRetwitteLabel.setButtonTitleColor(option: .gray)
        numFavoriteLabel.setButtonTitleColor(option: .gray)
        
        setupCell()
    }
    
    func setupCell () {
        userTweetForRetweet = nil
        
        contentImage.isHidden = true
        stackToContentImage.constant = 0
        contentImageHeight.constant = 0
        
        retweetStack.isHidden = true
        retweetLabelHeight.constant = 0
        avatarToRetweeted.constant = 5
    }
    
    private func updateUIWithTweetDetails () {
        
        if let username = userTweetForRetweet?.user?.name {
            if username == (UserModel.currentUser!.name) {
                retweetLabel.text = " You Retweeted"
            } else {
                retweetLabel.text = " \(username) Retweeted"
            }
            avatarToRetweeted.constant = 5
            retweetLabelHeight.constant = 20
            retweetStack.isHidden = false
        }
        
        if let avatarURL = tweet?.user?.profile_image_url {
            userAvatar.setImageWith(avatarURL)
        }
        
        if tweet.isUserRetweeted! == true {
            reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon-green"), for: .normal)
            numRetwitteLabel.setButtonTitleColor(option: .green)
        } else {
            reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon"), for: .normal)
            numRetwitteLabel.setButtonTitleColor(option: .gray)
        }
        
        if tweet.isUserFavorited! == true {
            favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon-red"), for: .normal)
            numFavoriteLabel.setButtonTitleColor(option: .red)
        } else {
            favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon"), for: .normal)
            numFavoriteLabel.setButtonTitleColor(option: .gray)
        }
        
        if let nameString = tweet?.user?.name {
            nameLabel.text = nameString
        } else {
            nameLabel.text = ""
        }
        
        if let screenNameString = tweet?.user!.screen_name {
            screenNameLabel.text = screenNameString
        } else {
            screenNameLabel.text = ""
        }
        
        if var contentString = tweet?.text {
            
            var tmpContentString = contentString
            
            if let media = tweet.media {
                if let mediaDictionary = media[0] as? NSDictionary {
                    let media_url = mediaDictionary["media_url_https"] as! String
                    let display_url = mediaDictionary["url"] as! String
                    // find the range in contentString where contains url
                    let type = mediaDictionary["type"] as! String
                    if type == "photo" {
                        if let range = tmpContentString.range(of: display_url) {
                            tmpContentString = contentString.replacingCharacters(in: range, with: "")
                            // reset attributedString with displayed url
                            contentString = tmpContentString
                        }
                        contentImage.isHidden = false
                        contentImage.alpha = 1.0
                        stackToContentImage.constant = 10
                        contentImageHeight.constant = contentImage.frame.width * 0.56
                        
                        let imageRequest = URLRequest(url: URL(string: media_url)!)
                        contentImage.setImageWith(imageRequest, placeholderImage: #imageLiteral(resourceName: "loadingImage"), success: { (request, response, image) in
                            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                                self.contentImage.image = image
                            })
                        })
                    }
                }
            }
            
            if let urls = tweet.urls {
                for item in urls {
                    if let urlDictionary = item as? NSDictionary {
                        let display_url = urlDictionary["display_url"] as! String
                        let url = urlDictionary["url"] as! String
                        
                        let urlPattern = display_url
                        let urlType = ActiveType.custom(pattern: urlPattern)
                        contentLabel.enabledTypes.append(urlType)
                        
                        contentLabel.customColor[urlType] = UIhelper.UIColorOption.twitterBlue
                        contentLabel.customSelectedColor[urlType] = UIhelper.UIColorOption.twitterGray
                        
                        contentLabel.handleCustomTap(for: urlType, handler: { (urlString) in
                            print(url)
                            UIApplication.shared.open(URL(string: url)!)
                        })
                        
                        // find the range in contentString where contains url
                        if let range = tmpContentString.range(of: url) {
                            // replace url to displayed url
                            tmpContentString = contentString.replacingCharacters(in: range, with: display_url)
                            // reset attributedString with displayed url
                            contentString = tmpContentString
                            
                        }
                    }
                }
            }
            contentLabel.text = contentString
        } else {
            contentLabel.text = ""
        }
        
        numReplyLabel.setTitle("", for: .normal)
        
        numRetwitteLabel.setTitle(self.tweet.retweetCount?.displayCountWithFormat(), for: .normal)
        numFavoriteLabel.setTitle(self.tweet.favoriteCount?.displayCountWithFormat(), for: .normal)
    }
    
    /// detect link only
    func isLinkTapped (sender: UITapGestureRecognizer) {
        print("Tapped")
    }
    
    func textView(_ textView: UITextView,
                           shouldInteractWith URL: URL,
                           in characterRange: NSRange,
                           interaction: UITextItemInteraction) -> Bool {
        print("I am here")
        return true
    }

    @IBAction func replyTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func retweetTapped(_ sender: UIButton) {
        var endpoint : String?
        
        // pop up menu
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        reTwitteButton.isEnabled = false
        numRetwitteLabel.isEnabled = false
        
        let tweetid = tweet.id!
        var title = "Retweet"
        var style = UIAlertActionStyle.default
        
        if tweet.isUserRetweeted! {
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
            
            self.reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon-blue"), for: .normal)
            self.numRetwitteLabel.setButtonTitleColor(option: .blue)
            
            self.client.post(endpoint!, parameters: nil, progress: nil, success: { (task, response) in
                print("retweet: success")
                
                var count = self.tweet.retweetCount!
                
                if self.tweet.isUserRetweeted! {
                    self.reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon"), for: .normal)
                    self.numRetwitteLabel.setButtonTitleColor(option: .gray)
                    count -= 1
                    self.tweet.isUserRetweeted = false
                } else {
                    self.reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon-green"), for: .normal)
                    self.numRetwitteLabel.setButtonTitleColor(option: .green)
                    self.tweet.isUserRetweeted = true
                    count += 1
                }
                self.tweet.retweetCount = count
                
                self.numRetwitteLabel.setTitle((count as Int).displayCountWithFormat(), for: .normal)
            }) { (task, error) in
                print(error)
                print("retweet: Error >>> \(error.localizedDescription)")
                self.reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon-yellow"), for: .normal)
                self.numRetwitteLabel.setButtonTitleColor(option: .yellow)
            }
        }
        alertController.addAction(retweetAction)
        
        if !tweet.isUserRetweeted! {
            let quoteTweetAction = UIAlertAction(title: "Quote Tweet(Unavailable)", style: .default) { (action) in
                /// handle case of quote tweet
            }
            alertController.addAction(quoteTweetAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        reTwitteButton.isEnabled = true
        numRetwitteLabel.isEnabled = true
        
        self.delegate?.showAlter(alertController: alertController)
    }
    
    @IBAction func favoritedTapped(_ sender: UIButton) {
        var endpoint : String?
        
        favoriteButton.isEnabled = false
        numFavoriteLabel.isEnabled = false
        
        favoriteButton.setImage(#imageLiteral(resourceName: "favorited-icon-blue"), for: .normal)
        numFavoriteLabel.setButtonTitleColor(option: .blue)
        
        if tweet.isUserFavorited! {
            endpoint = TwitterClient.APIScheme.FavoriteDestroyEndpoint
        } else {
            endpoint = TwitterClient.APIScheme.FavoriteCreateEndpoint
        }
        
        client.post(endpoint!, parameters: ["id" : tweet.id!], progress: nil, success: { (task, response) in
            print("retweet: success")
            
            var count = self.tweet.favoriteCount!
            
            if self.tweet.isUserFavorited! {
                self.favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon"), for: .normal)
                self.numFavoriteLabel.setButtonTitleColor(option: .gray)
                self.tweet.isUserFavorited = false
                count -= 1
            } else {
                self.favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon-red"), for: .normal)
                self.numFavoriteLabel.setButtonTitleColor(option: .red)
                self.tweet.isUserFavorited = true
                count += 1
            }
            
            self.tweet.favoriteCount = count
            
            self.numFavoriteLabel.setTitle((count as Int).displayCountWithFormat(), for: .normal)
        }) { (task, error) in
            print("retweet: Error >>> \(error.localizedDescription)")
            self.favoriteButton.setImage(#imageLiteral(resourceName: "favorited-icon-yellow"), for: .normal)
            self.numFavoriteLabel.setButtonTitleColor(option: .yellow)
        }
        
        favoriteButton.isEnabled = true
        numFavoriteLabel.isEnabled = true
    }

    @IBAction func messageTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            UIhelper.alertMessageWithAction("Delete Tweet", userMessage: "Are you sure you want to delete this Tweet?", left: "Cancel", right: "Delete", leftAction: nil, rightAction: { (action) in
                var endpoint = TwitterClient.APIScheme.TweetStatusDestroyEndpoint
                if let range = endpoint.range(of: ":id") {
                    endpoint = endpoint.replacingCharacters(in: range, with: "\(self.tweet.id!)")
                }
                
                self.client.post(endpoint, parameters: nil, progress: nil, success: { (task, response) in
                    print("Delete tweet: Success")
                    
                    self.delegate?.removeCell(index: self.index)
                    
                }, failure: { (task, error) in
                    print("\(error.localizedDescription)")
                })
            }, sender: (UIApplication.shared.keyWindow?.rootViewController)!)
        }
        if tweet.user?.id == UserModel.currentUser?.id {
            alertController.addAction(deleteAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.delegate?.showAlter(alertController: alertController)
    }
    
}

extension NSMutableAttributedString {
    public func setLink(textToFind:String, linkURL:String) -> Bool {
        
        let range = self.mutableString.range(of: textToFind)
        if range.location != NSNotFound {
            self.addAttribute(NSLinkAttributeName, value: linkURL, range: range)
            return true
        }
        return false
    }
}
