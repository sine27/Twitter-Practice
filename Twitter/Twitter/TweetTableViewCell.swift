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
    
    var cellIndex: Int? {
        didSet {
            reTwitteButton?.tag = cellIndex!
            replyButton?.tag = cellIndex!
            favoriteButton?.tag = cellIndex!
            menuButton?.tag = cellIndex!
            imageView?.tag = cellIndex!
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
            view.removeGestureRecognizer(tapGesture)
            view.removeFromSuperview()
        }
        for view in contentStack1.subviews {
            view.removeGestureRecognizer(tapGesture)
            view.removeFromSuperview()
        }
        
        contentImage.distribution = .fill
        contentStack0.distribution = .fill
        contentStack1.distribution = .fill
        stack1width.constant = 0
        
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
        
        if let avatarURL = tweet?.user?.profile_image_url {
            userAvatar.setImageWith(avatarURL)
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
            
            if let media = tweet.media {
                
                contentImage.isHidden = false
                contentImage.alpha = 1.0
                stackToContentImage.constant = 15
                
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
                        
                        //playButton = UIButton(frame: CGRect(origin: imageView.center, size: CGSize(width: 50, height: 50)))
                        playButton = UIButton(frame: CGRect(x: stackWidth / 2 - 25, y: contentImageHeight.constant / 2 - 25, width: 50, height: 50))
                        playButton.setImage(#imageLiteral(resourceName: "video-icon"), for: .normal)
                        playButton.addTarget(self, action: #selector(playTapped(sender:)), for: .touchUpInside)
                        
                        let video_info = mediaDictionary["video_info"] as! NSDictionary
                        let variants = video_info["variants"] as! [NSDictionary]
                        let variant = variants[0]
                        let urlString = variant["url"] as! String
                        
                        videoUrl = urlString
                        
                        contentStack0.addArrangedSubview(imageView)
                        contentImage.addSubview(playButton)
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
    
    func popOverImage (sender: UITapGestureRecognizer) {
        print("Tapped")
        self.popDelegate?.getPopoverImage(imageView: sender.view as! UIImageView)
    }
    
    func openVideo (sender: UITapGestureRecognizer) {
        UIApplication.shared.open(URL(string: videoUrl!)!)
    }
    
    func playTapped (sender: UIButton!) {
        
        playButton.removeFromSuperview()
        
        let playerView = contentStack0.subviews[0]
        
        self.layoutIfNeeded()
        
        playerView.frame = contentImage.bounds
        
        player = AVPlayer(url: URL(string: videoUrl!)!)
        
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = contentImage.bounds
        
        playerView.layer.addSublayer(playerLayer)
        
        player.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func playerDidFinishPlaying(note: NSNotification) {
        print("Play end")
        playButton.setImage(#imageLiteral(resourceName: "video-icon"), for: .normal)
        contentImage.addSubview(playButton)
    }
    
    func showProfile(sender: UITapGestureRecognizer) {
        print("Tapped")
        self.delegate?.tweetCellUserProfileImageTapped!(cell: self, forTwitterUser: tweet.user)
    }
    
    @IBAction func replyTapped(_ sender: UIButton) {
        
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
