//
//  TweetTableViewCell.swift
//  Twitter
//
//  Created by Shayin Feng on 3/2/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import AFNetworking
import ActiveLabel
import SwiftGifOrigin
import AVKit
import AVFoundation

@objc protocol TweetTableViewCellDelegate: class {
    @objc optional func tweetCellFavoritedTapped(cell: TweetTableViewCell, isFavorited: Bool)
    @objc optional func tweetCellRetweetTapped(cell: TweetTableViewCell, isRetweeted: Bool)
    @objc optional func tweetCellReplyTapped(cell: TweetTableViewCell, withId: Int)
    @objc optional func tweetCellMenuTapped(cell: TweetTableViewCell, withId id: Int)
    @objc optional func tweetCellUserProfileImageTapped(cell: TweetTableViewCell, forTwitterUser user: UserModel?)
}

class TweetTableViewCell: UITableViewCell {

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

    @IBOutlet weak var contentMediaView: UIView!
    
    @IBOutlet weak var contentMediaHeight: NSLayoutConstraint!
    
    @IBOutlet weak var stackToContentMedia: NSLayoutConstraint!
    
    @IBOutlet weak var retweetLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var retweetStack: UIStackView!
    
    @IBOutlet weak var retweetLabel: UILabel!
    
    @IBOutlet weak var avatarToRetweeted: NSLayoutConstraint!
    
    @IBOutlet weak var contentToName: NSLayoutConstraint!
    
    var tapGesture = UITapGestureRecognizer()
    
    var delegate: TweetTableViewCellDelegate?
    
    var popDelegate: TweetTableViewDelegate?
    
    let client = TwitterClient.sharedInstance!
    
    var index: IndexPath!
    
    var videoUrl: String?
    
    var player = AVPlayer()
    
    var playButton = UIButton()
    
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
        contentMediaView.layer.masksToBounds = true
        contentMediaView.layer.cornerRadius = 5

        self.layoutIfNeeded()
        self.layoutSubviews()
        
        contentLabel.customize { contentLabel in
            
            contentLabel.handleHashtagTap { hashtag in
                print("Success. You just tapped the \(hashtag) hashtag")
            }
            contentLabel.handleMentionTap { (mention) in
                print("Success. You just tapped the \(mention) mention")
            }
            contentLabel.removeHandle(for: ActiveType.url)
        }
        setupCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
//        userAvatar.image = #imageLiteral(resourceName: "noImage")
//        reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon"), for: .normal)
//        favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon"), for: .normal)
//        numRetwitteLabel.setButtonTitleColor(option: .gray)
//        numFavoriteLabel.setButtonTitleColor(option: .gray)
        
        setupCell()
    }
    
    func setupCell () {
        userTweetForRetweet = nil
        
        contentMediaView.isHidden = true
        stackToContentMedia.constant = 3
        contentMediaHeight.constant = 0
        
        contentMediaView.translatesAutoresizingMaskIntoConstraints = false
        
        retweetStack.isHidden = true
        retweetLabelHeight.constant = 0
        avatarToRetweeted.constant = 5

        playButton.removeFromSuperview()
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
        
        if let avatarURL = tweet?.user?.profile_image_url_https {
            userAvatar.setImageWith(URLRequest(url: avatarURL), placeholderImage: #imageLiteral(resourceName: "noImage"), success: { (request, response, image) in
                self.userAvatar.image = image
            }, failure: { (request, response, error) in
                if self.tweet?.user?.profile_image_url != nil {
                    self.userAvatar.setImageWith((self.tweet?.user?.profile_image_url)!)
                }
            })
            userAvatar.isUserInteractionEnabled = true
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(sender:)))
            userAvatar.addGestureRecognizer(tapGesture)
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
            if let verified = tweet.user?.verified {
                if verified == true {
                    let attachment = NSTextAttachment()
                    attachment.image = #imageLiteral(resourceName: "verified-account")
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
        
        if let screenNameString = tweet?.user!.screen_name {
            screenNameLabel.text = screenNameString
        } else {
            screenNameLabel.text = ""
        }
        
        if var contentString = tweet?.text {
            
            var tmpContentString = contentString
            
            // should show medias
            if let media = tweet.media {
                
                // should show media view, height should be set based on situation
                contentMediaView.isHidden = false
                stackToContentMedia.constant = 15
                
                // width of contentMediaView
                let frameWidth = contentMediaView.frame.width
                
                // count of images or video in data model
                let mediaCount = media.count
                var photoCount = 0
                
                // image collection frames 
                let imageCollectionHeight = frameWidth * 0.56
                let frame1 = CGRect(x: 0, y: 0, width: frameWidth, height: imageCollectionHeight)

                let stack0 = UIStackView(frame: frame1)
                let stack1 = UIStackView()
                let stack2 = UIStackView()
                
                stack0.axis = .horizontal
                stack0.distribution = .fillEqually
                stack0.alignment = .fill
                stack0.spacing = 4
                
                stack1.axis = .vertical
                stack1.distribution = .fillEqually
                stack1.alignment = .fill
                stack1.spacing = 4
                
                stack2.axis = .vertical
                stack2.distribution = .fillEqually
                stack2.alignment = .fill
                stack2.spacing = 4
                
                if mediaCount > 2 {
                    stack0.addArrangedSubview(stack1)
                    stack0.addArrangedSubview(stack2)
                }
                
                // madia is NSArray which stores NSDictionaries
                for mediaDictionary in media as! [NSDictionary] {
                    
                    let media_url = mediaDictionary["media_url"] as! String
                    let url_should_be_replaced = mediaDictionary["url"] as! String
                    
                    // photo, animated_gif
                    let type = mediaDictionary["type"] as! String
                    
                    // range of url which should be replaced by images or video
                    if let range = tmpContentString.range(of: url_should_be_replaced) {
                        tmpContentString = contentString.replacingCharacters(in: range, with: "")
                        contentString = tmpContentString
                    }
                    
                    let imageView = UIImageView()
                    imageView.image = #imageLiteral(resourceName: "loadingImage")
                    imageView.clipsToBounds = true
                    imageView.contentMode = .scaleAspectFill
                    
                    if type == "animated_gif" {
                        
                        // view for animated gif is original
                        let size = mediaDictionary["sizes"] as! NSDictionary
                        let large = size["large"] as! NSDictionary
                        let h = large["h"] as! CGFloat
                        let w = large["w"] as! CGFloat
                        let ratio = h / w
                        
                        // content media view height
                        let frameHeight = frameWidth * ratio
                        contentMediaHeight.constant = frameHeight
                        
                        // setup image frame
                        imageView.frame = CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight)

                        // cache image
                        let imageRequest = URLRequest(url: URL(string: media_url)!)
                        imageView.setImageWith(imageRequest, placeholderImage: #imageLiteral(resourceName: "loadingImage"), success: { (request, response, image) in
                            imageView.image = image
                        })
                        
                        // tap to view image in fullscreen
                        imageView.isUserInteractionEnabled = true
                        tapGesture = UITapGestureRecognizer(target: self, action: #selector(openVideo(sender:)))
                        imageView.addGestureRecognizer(tapGesture)

                        // play Button for video
                        playButton = UIButton(frame: CGRect(x: (frameWidth / 2 - 25), y: (frameHeight / 2 - 25), width: 50, height: 50))
                        playButton.setImage(#imageLiteral(resourceName: "play-icon"), for: .normal)
                        playButton.addTarget(self, action: #selector(playTapped(sender:)), for: .touchUpInside)
                        
                        // video infromation in dictionary
                        let video_info = mediaDictionary["video_info"] as! NSDictionary
                        let variants = video_info["variants"] as! [NSDictionary]
                        let variant = variants[0]
                        let urlString = variant["url"] as! String
                        
                        videoUrl = urlString
                        
                        contentMediaView.addSubview(imageView)
                        contentMediaView.addSubview(playButton)
                    }
                        
                    else if type == "photo" {
                        
                        contentMediaHeight.constant = imageCollectionHeight
                        
                        let imageRequest = URLRequest(url: URL(string: media_url)!)
                        imageView.setImageWith(imageRequest, placeholderImage: #imageLiteral(resourceName: "loadingImage"), success: { (request, response, image) in
                            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                                imageView.image = image
                            })
                        })
                        
                        imageView.isUserInteractionEnabled = true
                        tapGesture = UITapGestureRecognizer(target: self, action: #selector(popOverImage(sender:)))
                        imageView.addGestureRecognizer(tapGesture)
                        
                        
                        if mediaCount == 1 {
                            imageView.frame = frame1
                            contentMediaView.addSubview(imageView)
                        }
                        else if mediaCount == 2 {
                            stack0.addArrangedSubview(imageView)
                        }
                        else if mediaCount == 3 {
                            if photoCount == 0 {
                                stack1.addArrangedSubview(imageView)
                            } else {
                                stack2.addArrangedSubview(imageView)
                            }
                        }
                        else if mediaCount == 4 {
                            if photoCount == 0 || photoCount == 2 {
                                stack1.addArrangedSubview(imageView)
                            } else {
                                stack2.addArrangedSubview(imageView)
                            }
                        }
                        else {
                            print("Photo Collection: Media count invalid")
                        }
                        photoCount += 1
                    }
                }
                if mediaCount >= 2 {
                    contentMediaView.addSubview(stack0)
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
        
        if contentLabel.text == "" {
            contentToName.constant = -18
        }
        
        numReplyLabel.setTitle("", for: .normal)
        
        numRetwitteLabel.setTitle(self.tweet.retweetCount?.displayCountWithFormat(), for: .normal)
        numFavoriteLabel.setTitle(self.tweet.favoriteCount?.displayCountWithFormat(), for: .normal)
    }
    
    /// detect link only
    func isLinkTapped (sender: UITapGestureRecognizer) {
        print("Tapped")
    }
    
    func popOverImage (sender: UITapGestureRecognizer) {
        print("Tapped")
        self.popDelegate?.getPopoverImage(imageView: sender.view as! UIImageView)
    }
    
    func openVideo (sender: UITapGestureRecognizer) {
        UIApplication.shared.open(URL(string: videoUrl!)!)
    }
    
    func playTapped (sender: UIButton!) {
        
        playButton.removeFromSuperview()
        
        let playerView = contentMediaView.subviews[0]
        
        self.layoutIfNeeded()
        
        playerView.frame = contentMediaView.bounds
        
        player = AVPlayer(url: URL(string: videoUrl!)!)
        
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = contentMediaView.bounds
        
        playerView.layer.addSublayer(playerLayer)
        
        player.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func playerDidFinishPlaying(note: NSNotification) {
        print("Play end")
        playButton.setImage(#imageLiteral(resourceName: "play-icon"), for: .normal)
        contentMediaView.addSubview(playButton)
    }
    
    func showProfile(sender: UITapGestureRecognizer) {
        print("Tapped")
        self.delegate?.tweetCellUserProfileImageTapped!(cell: self, forTwitterUser: tweet.user)
    }
    
    @IBAction func replyTapped(_ sender: UIButton) {
        self.delegate?.tweetCellReplyTapped!(cell: self, withId: tweet.id!)
    }
    
    @IBAction func retweetTapped(_ sender: UIButton) {
        if let isRetweeted = tweet.isUserRetweeted {
            delegate?.tweetCellRetweetTapped?(cell: self, isRetweeted: isRetweeted)
        }
    }
    
    @IBAction func favoritedTapped(_ sender: UIButton) {
        if let isFavorited = tweet.isUserFavorited {
            delegate?.tweetCellFavoritedTapped?(cell: self, isFavorited: isFavorited)
        }
    }
    
    @IBAction func messageTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        delegate?.tweetCellMenuTapped?(cell: self, withId: tweet.id!)
    }

}
