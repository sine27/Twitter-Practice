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

class TweetTableViewCell: UITableViewCell {
    
    var viewModel: TwitterTableCellViewModel! {
        didSet {
            updateButtonImageWithState()
            configure()
        }
    }

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
    
    let AVATAR_PLAEHOLDER_IMAGE = #imageLiteral(resourceName: "noImage")
    
    var tapGesture = UITapGestureRecognizer()
    
    var delegate: TweetTableViewCellDelegate?
    
    var popDelegate: TweetTableViewDelegate?
    
    let client = TwitterClient.sharedInstance!
    
    var index: IndexPath!
    
    var videoUrl: String?
    
    var player = AVPlayer()
    
    var playButton = UIButton()
    
    
    
    @IBAction func replyTapped(_ sender: UIButton) {
        self.delegate?.tweetCellReplyTapped!(cell: self, withId: viewModel.tweetForShow.id!)
    }
    
    @IBAction func retweetTapped(_ sender: UIButton) {
        delegate?.tweetCellRetweetTapped?(cell: self, isRetweeted: viewModel.isTweetRetweeted())
    }
    
    @IBAction func favoritedTapped(_ sender: UIButton) {
        delegate?.tweetCellFavoritedTapped?(cell: self, isFavorited: viewModel.isTweetFavorited())
    }
    
    @IBAction func messageTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        delegate?.tweetCellMenuTapped?(cell: self, withId: viewModel.tweetForShow.id!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userAvatar.layer.masksToBounds = true
        userAvatar.layer.cornerRadius = 5
        userAvatar.layer.borderColor = UIColor.lightGray.cgColor
        userAvatar.layer.borderWidth = 0.5
        userAvatar.image = #imageLiteral(resourceName: "noImage")
        reTwitteButton.isEnabled = true
        numRetwitteLabel.isEnabled = true
        favoriteButton.isEnabled = true
        numFavoriteLabel.isEnabled = true
        contentMediaView.layer.masksToBounds = true
        contentMediaView.layer.cornerRadius = 5
        
        favoriteButton.setImage(#imageLiteral(resourceName: "favorited-icon-dark"), for: .disabled)
        reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon-green"), for: .normal)
        reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon-dark"), for: .disabled)
        
        self.layoutIfNeeded()
        self.layoutSubviews()
        
        contentLabel.customize { contentLabel in
            contentLabel.handleHashtagTap { hashtag in
                print("Success. You just tapped the \(hashtag) hashtag")
            }
            contentLabel.handleMentionTap { (mention) in
                print("Success. You just tapped the \(mention) mention")
                self.delegate?.tweetCellMentionTapped!(with: mention)
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
    
    func updateButtonImageWithState() {
        favoriteButton.setImage(viewModel.isTweetFavorited() ? #imageLiteral(resourceName: "favor-icon-red"):#imageLiteral(resourceName: "favor-icon"), for: .normal)
        reTwitteButton.setImage(viewModel.isTweetRetweeted() ? #imageLiteral(resourceName: "retweet-icon-green"):#imageLiteral(resourceName: "retweet-icon"), for: .normal)
        numFavoriteLabel.setButtonTitleColor(option: viewModel.isTweetFavorited() ? .red:.gray)
        numRetwitteLabel.setButtonTitleColor(option: viewModel.isTweetRetweeted() ? .green:.gray)
    }
    
    func setupCell () {
        contentMediaView.isHidden = true
        stackToContentMedia.constant = 3
        contentMediaHeight.constant = 0
        
        contentMediaView.translatesAutoresizingMaskIntoConstraints = false
        
        retweetStack.isHidden = true
        retweetLabelHeight.constant = 0
        avatarToRetweeted.constant = 5
        
        playButton.removeFromSuperview()
    }
    
    func configure() {
        timeCreateLabel.text = viewModel.getTimePosted()
        screenNameLabel.text = viewModel.getScreenName()
        numRetwitteLabel.setTitle(viewModel.tweetForShow.retweetCount?.displayCountWithFormat(), for: .normal)
        numFavoriteLabel.setTitle(viewModel.tweetForShow.favoriteCount?.displayCountWithFormat(), for: .normal)
        numReplyLabel.setTitle("", for: .normal)
        
        /// retweet note
        if viewModel.isTweetRetweeted() {
            if let note = viewModel.getRetweetNote() {
                retweetLabel.text = note
                avatarToRetweeted.constant = 5
                retweetLabelHeight.constant = 20
                retweetStack.isHidden = false
            }
        }
        
        /// User avatar
        if let avatarURL = viewModel.getAvatarImageURL(withHttps: true) {
            userAvatar.setImageWith(URLRequest(url: avatarURL), placeholderImage: AVATAR_PLAEHOLDER_IMAGE, success: { (request, response, image) in
                self.userAvatar.image = image
            }, failure: { (request, response, error) in
                if let url = self.viewModel.getAvatarImageURL(withHttps: false) {
                    self.userAvatar.setImageWith(url)
                }
            })
            userAvatar.isUserInteractionEnabled = true
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile(sender:)))
            userAvatar.addGestureRecognizer(tapGesture)
        } else {
            userAvatar.image = AVATAR_PLAEHOLDER_IMAGE
        }
        
        /// Username
        let nameString = viewModel.getUsername()
        if viewModel.isUserVerified() {
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
        
        /// Content
        var contentString = viewModel.tweetForShow.text ?? ""
        if contentString.characters.count > 0 {
            if viewModel.hasMedia() {
                contentString = setUpMediaStack(for: viewModel.tweetForShow.media!.count, with: viewModel.tweetForShow.media!, content: contentString)
            }
            contentString = setupUrls(content: contentString)
        } else {
            contentToName.constant = -18
        }
        contentLabel.text = contentString
        
        
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
        self.delegate?.tweetCellUserProfileImageTapped!(cell: self, forTwitterUser: viewModel.tweetForShow.user)
    }
    
    func setUpMediaStack(for count: Int, with media: [MediaModel], content: String) -> String {
        // should show media view, height should be set based on situation
        contentMediaView.isHidden = false
        stackToContentMedia.constant = 15
        
        // width of contentMediaView
        let frameWidth = contentMediaView.frame.width
        
        // count of images or video in data model
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
        
        if count > 2 {
            stack0.addArrangedSubview(stack1)
            stack0.addArrangedSubview(stack2)
        }
        
        var contentCopy = content
        
        // madia is NSArray which stores NSDictionaries
        for m in media {
            contentCopy = viewModel.getContentAfterMediaUrlReplaced(with: m, content: contentCopy)
            
            let imageView = UIImageView()
            imageView.image = #imageLiteral(resourceName: "loadingImage")
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.layer.borderColor = UIColor.lightGray.cgColor
            imageView.layer.borderWidth = 0.5
            
            if m.type == "animated_gif" {
                
                // content media view height
                let frameHeight = frameWidth * m.mediaRatio
                contentMediaHeight.constant = frameHeight
                
                // setup image frame
                imageView.frame = CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight)
                
                // cache image
                let imageRequest = URLRequest(url: URL(string: m.media_url)!)
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
                
                
                videoUrl = viewModel.getVideoUrlString(with: m)
                
                contentMediaView.addSubview(imageView)
                contentMediaView.addSubview(playButton)
            }
                
            else if m.type == "photo" {
                
                contentMediaHeight.constant = imageCollectionHeight
                
                let imageRequest = URLRequest(url: URL(string: m.media_url)!)
                imageView.setImageWith(imageRequest, placeholderImage: #imageLiteral(resourceName: "loadingImage"), success: { (request, response, image) in
                    UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                        imageView.image = image
                    })
                })
                
                imageView.isUserInteractionEnabled = true
                tapGesture = UITapGestureRecognizer(target: self, action: #selector(popOverImage(sender:)))
                imageView.addGestureRecognizer(tapGesture)
                
                
                if count == 1 {
                    imageView.frame = frame1
                    contentMediaView.addSubview(imageView)
                }
                else if count == 2 {
                    stack0.addArrangedSubview(imageView)
                }
                else if count == 3 {
                    if photoCount == 0 {
                        stack1.addArrangedSubview(imageView)
                    } else {
                        stack2.addArrangedSubview(imageView)
                    }
                }
                else if count == 4 {
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
        if count >= 2 {
            contentMediaView.addSubview(stack0)
        }
        return content
    }
    
    func setupUrls(content: String) -> String {
        if let urls = viewModel.tweetForShow.urls {
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
                    
                    var tmp = content
                    // find the range in contentString where contains url
                    if let range = tmp.range(of: url) {
                        // replace url to displayed url
                        tmp = content.replacingCharacters(in: range, with: display_url)
                        // reset attributedString with displayed url
                        return tmp
                    }
                }
            }
        }
        return content
    }
}
