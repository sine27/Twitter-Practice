//
//  TweetDetailTableViewCell.swift
//  Twitter
//
//  Created by Shayin Feng on 2/25/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import ActiveLabel
import AVKit
import AVFoundation

@objc protocol TweetDetailTableViewCellDelegate: class {
    @objc optional func tweetCellMenuTapped(cell: TweetDetailTableViewCell, withId id: Int)
    @objc optional func tweetCellUserProfileImageTapped(cell: TweetDetailTableViewCell, forTwitterUser user: UserModel?)
    
}

class TweetDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var screenLabel: UILabel!
    
    @IBOutlet weak var contentLabel: ActiveLabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var contentMediaView: UIView!
    
    @IBOutlet weak var contentMediaHeight: NSLayoutConstraint!
    
    @IBOutlet weak var timeLabelToImage: NSLayoutConstraint!
    
    @IBOutlet weak var retweetStack: UIStackView!
    
    @IBOutlet weak var retweetStackHeight: NSLayoutConstraint!
    
    @IBOutlet weak var retweetStackLabel: UILabel!
    
    @IBOutlet weak var avatarToRetweetStack: NSLayoutConstraint!
    
    @IBOutlet weak var contentToAvatar: NSLayoutConstraint!
    
    var tapGesture = UITapGestureRecognizer()
    
    var delegate: TweetDetailTableViewCellDelegate?
    
    var popDelegate: TweetTableViewDelegate?
    
    let client = TwitterClient.sharedInstance!
    
    var videoUrl: String?
    
    var player = AVPlayer()
    
    var playButton = UIButton()
    
    var tweet: TweetModel! {
        didSet {
            updateUIWithTweetDetails()
        }
    }
    
    var retweet: TweetModel? {
        didSet {
            if let username = retweet?.user?.name {
                if username == (UserModel.currentUser!.name) {
                    retweetStackLabel.text = " You Retweeted"
                } else {
                    retweetStackLabel.text = " \(username) Retweeted"
                }
                avatarToRetweetStack.constant = 10
                retweetStackHeight.constant = 20
                retweetStack.isHidden = false
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = 5
        avatarImage.image = #imageLiteral(resourceName: "noImage")
        timeLabelToImage.constant = 3
        contentMediaView.layer.masksToBounds = true
        contentMediaView.layer.cornerRadius = 5
        
        self.layoutIfNeeded()
        
        contentLabel.customize { contentLabel in
            
            contentLabel.handleHashtagTap { hashtag in
                print("Success. You just tapped the \(hashtag) hashtag")
            }
            contentLabel.handleURLTap { (mention) in
                print("Success. You just tapped the \(mention) mention")
            }
            contentLabel.removeHandle(for: ActiveType.url)
        }
    }
    
    override func prepareForReuse() {
        contentMediaHeight.constant = 0
        timeLabelToImage.constant = 3
        
        contentMediaView.translatesAutoresizingMaskIntoConstraints = false
        
        retweetStackHeight.constant = 0
        avatarToRetweetStack.constant = 5
        retweetStack.isHidden = true
        
        playButton.removeFromSuperview()
        
    }
    
    private func updateUIWithTweetDetails () {
        
        if let avatarURL = tweet?.user?.profile_image_url {
            avatarImage.setImageWith(avatarURL)
        }
        
        if let nameString = tweet?.user?.name {
            if let verified = tweet.user?.verified {
                if verified == true {
                    let attachment = NSTextAttachment()
                    attachment.image = #imageLiteral(resourceName: "verified-account")
                    // attachment.image = UIImage(cgImage: (attachment.image?.cgImage)!, scale: 6, orientation: .up)
                    attachment.bounds = CGRect(x: 0, y: -4, width: 18, height: 18)
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
            screenLabel.text = screenNameString
        } else {
            screenLabel.text = ""
        }
        
        if let timeCreated = tweet?.createdAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy, HH:mm"
            timeLabel.text = dateFormatter.string(from: timeCreated)
        }
        
        if var contentString = tweet?.text {
            
            var tmpContentString = contentString
            
            // should show medias
            if let media = tweet.media {
                
                // should show media view, height should be set based on situation
                contentMediaView.isHidden = false
                timeLabelToImage.constant = 15
                
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
                    
                    // ratio for original
                    let size = mediaDictionary["sizes"] as! NSDictionary
                    let large = size["large"] as! NSDictionary
                    let h = large["h"] as! CGFloat
                    let w = large["w"] as! CGFloat
                    let ratio = h / w
                    let frameHeight = frameWidth * ratio
                    
                    let imageView = UIImageView()
                    imageView.image = #imageLiteral(resourceName: "loadingImage")
                    imageView.clipsToBounds = true
                    imageView.contentMode = .scaleAspectFill
                    
                    if type == "animated_gif" {
                        
                        // content media view height
                        contentMediaHeight.constant = frameHeight

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
                            contentMediaHeight.constant = frameHeight
                            imageView.frame = CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight)
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
                        
                        print("\(tmpContentString)  \(url)")
                        
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
            contentToAvatar.constant = -25
        }
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
        contentMediaView.addSubview(playButton)
    }

    @IBAction func menuButtonTapped(_ sender: UIButton) {
        self.delegate?.tweetCellMenuTapped!(cell: self, withId: tweet.id!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
