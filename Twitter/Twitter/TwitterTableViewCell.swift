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
import SwiftGifOrigin
import AVKit
import AVFoundation

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
    
    @IBOutlet weak var contentImage: UIStackView!
    
    @IBOutlet weak var contentStack0: UIStackView!
    
    @IBOutlet weak var contentStack1: UIStackView!
    
    @IBOutlet weak var contentImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var stackToContentImage: NSLayoutConstraint!
    
    @IBOutlet weak var retweetLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var retweetStack: UIStackView!
    
    @IBOutlet weak var retweetLabel: UILabel!
    
    @IBOutlet weak var avatarToRetweeted: NSLayoutConstraint!
    
    @IBOutlet weak var stack1width: NSLayoutConstraint!
    
    @IBOutlet weak var stack0width: NSLayoutConstraint!
    
    var tapGesture = UITapGestureRecognizer()
    
    var delegate: SubviewViewControllerDelegate?
    
    var popDelegate: PreviewViewDelegate?
    
    let client = TwitterClient.sharedInstance!
    
    var index: IndexPath!
    
    var videoUrl: String?
    
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
        reTwitteButton.isEnabled = true
        numRetwitteLabel.isEnabled = true
        favoriteButton.isEnabled = true
        numFavoriteLabel.isEnabled = true
        
        contentStack0.translatesAutoresizingMaskIntoConstraints = false
        contentStack0.alignment = UIStackViewAlignment.center
        contentStack0.spacing   = 4
        contentStack0.clipsToBounds = true
        contentStack1.translatesAutoresizingMaskIntoConstraints = false
        contentStack1.alignment = UIStackViewAlignment.center
        contentStack1.spacing   = 4
        contentStack1.clipsToBounds = true
        contentImage.translatesAutoresizingMaskIntoConstraints = false
        contentImage.alignment = UIStackViewAlignment.center
        contentImage.spacing   = 4
        contentImage.clipsToBounds = true
        
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
        stackToContentImage.constant = 3
        contentImageHeight.constant = 0
        
        retweetStack.isHidden = true
        retweetLabelHeight.constant = 0
        avatarToRetweeted.constant = 5
        
        for view in contentStack0.subviews {
            view.removeFromSuperview()
        }
        for view in contentStack1.subviews {
            view.removeFromSuperview()
        }
        
        contentImage.distribution = .fill
        contentStack0.distribution = .fill
        contentStack1.distribution = .fill
        stack1width.constant = 0
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
                
                contentImage.isHidden = false
                contentImage.alpha = 1.0
                stackToContentImage.constant = 8
                
                let stackWidth = contentImage.frame.width
                
                var photoCount = 0
                
                for mediaDictionary in media as! [NSDictionary] {
                    let media_url = mediaDictionary["media_url"] as! String
                    let display_url = mediaDictionary["url"] as! String
                    // find the range in contentString where contains url
                    let type = mediaDictionary["type"] as! String
                    
                    if let range = tmpContentString.range(of: display_url) {
                        tmpContentString = contentString.replacingCharacters(in: range, with: "")
                        // reset attributedString with displayed url
                        contentString = tmpContentString
                    }
                    
                    if type == "animated_gif" {

                        let size = mediaDictionary["sizes"] as! NSDictionary
                        let large = size["large"] as! NSDictionary
                        let h = large["h"] as! CGFloat
                        let w = large["w"] as! CGFloat
                        let ratio = h / w
                        contentImageHeight.constant = stackWidth * ratio
                        
                        let imageView = UIImageView()
                        
                        let imageRequest = URLRequest(url: URL(string: media_url)!)
                        imageView.setImageWith(imageRequest, placeholderImage: #imageLiteral(resourceName: "loadingImage"), success: { (request, response, image) in
                            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                                imageView.image = image
                            })
                        })
                        imageView.heightAnchor.constraint(equalToConstant: stackWidth * ratio).isActive = true
                        imageView.widthAnchor.constraint(equalToConstant: stackWidth).isActive = true
                        
                        imageView.contentMode = .scaleAspectFill
                        imageView.clipsToBounds = true
                        imageView.layer.masksToBounds = true
                        imageView.layer.cornerRadius = 5
                        
                        imageView.isUserInteractionEnabled = true
                        tapGesture = UITapGestureRecognizer(target: self, action: #selector(openVideo(sender:)))
                        imageView.addGestureRecognizer(tapGesture)

                        
                        
                        let video_info = mediaDictionary["video_info"] as! NSDictionary
                        let variants = video_info["variants"] as! [NSDictionary]
                        let variant = variants[0]
                        let urlString = variant["url"] as! String
                        
                        videoUrl = urlString
//
//                        let playerView = UIView()
//                        
//                        self.layoutIfNeeded()
//                        
//                        playerView.frame = contentStack0.bounds
//                        
//                        let videoURL = URL(string: urlString)
//
//                        let player = AVPlayer(url: videoURL!)
//                        
//                        let playerLayer = AVPlayerLayer(player: player)
//                    
//                        playerLayer.frame = playerView.bounds
//                        
//                        playerView.layer.addSublayer(playerLayer)
//
//                        player.play()
//                        
                        contentStack0.addArrangedSubview(imageView)
                    }
                    
                    else if type == "photo" {
                        contentImageHeight.constant = contentImage.frame.width * 0.56
                        let imageView = UIImageView()
                        
                        let imageRequest = URLRequest(url: URL(string: media_url)!)
                        imageView.setImageWith(imageRequest, placeholderImage: #imageLiteral(resourceName: "loadingImage"), success: { (request, response, image) in
                            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                                imageView.image = image
                            })
                        })
                        
                        imageView.contentMode = .scaleAspectFill
                        imageView.clipsToBounds = true
                        imageView.layer.masksToBounds = true
                        imageView.layer.cornerRadius = 5
                        
                        imageView.isUserInteractionEnabled = true
                        tapGesture = UITapGestureRecognizer(target: self, action: #selector(popOverImage(sender:)))
                        imageView.addGestureRecognizer(tapGesture)
                        
                        switch photoCount {
                        case 0:
                            let sh = imageView.heightAnchor.constraint(equalToConstant: contentImageHeight.constant)
                            let sw = imageView.widthAnchor.constraint(equalToConstant: stackWidth)
                            sh.isActive = true
                            sh.priority = 500
                            sw.isActive = true
                            sw.priority = 500
                            contentStack0.addArrangedSubview(imageView)
                        case 1:
                            contentImage.distribution = .fillEqually
                            contentStack1.addArrangedSubview(imageView)
                        case 2:
                            contentStack1.distribution = .fillEqually
                            contentStack1.addArrangedSubview(imageView)
                        case 3:
                            contentStack0.distribution = .fillEqually
                            contentStack0.addArrangedSubview(imageView)
                        default:
                            contentImageHeight.constant = 0
                        }
                        
                        photoCount += 1
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
    
    func popOverImage (sender: UITapGestureRecognizer) {
        print("Tapped")
        self.popDelegate?.getPopoverImage(imageView: sender.view as! UIImageView)
    }
    
    func openVideo (sender: UITapGestureRecognizer) {
        UIApplication.shared.open(URL(string: videoUrl!)!)
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
