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
    
    //@IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var contentImage: UIStackView!
    
    @IBOutlet weak var contentStack0: UIStackView!
    
    @IBOutlet weak var contentStack1: UIStackView!
    
    @IBOutlet weak var contentImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var timeLabelToImage: NSLayoutConstraint!
    
    @IBOutlet weak var stack1width: NSLayoutConstraint!
    
    @IBOutlet weak var retweetStack: UIStackView!
    
    @IBOutlet weak var retweetStackHeight: NSLayoutConstraint!
    
    @IBOutlet weak var retweetStackLabel: UILabel!
    
    @IBOutlet weak var avatarToRetweetStack: NSLayoutConstraint!
    
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
        contentImage.layer.masksToBounds = true
        contentImage.layer.cornerRadius = 20
        timeLabelToImage.constant = 3
        
        contentStack0.translatesAutoresizingMaskIntoConstraints = false
        contentStack0.alignment = UIStackViewAlignment.center
        contentStack0.spacing   = 5
        contentStack0.clipsToBounds = true
        contentStack1.translatesAutoresizingMaskIntoConstraints = false
        contentStack1.alignment = UIStackViewAlignment.center
        contentStack1.spacing   = 5
        contentStack1.clipsToBounds = true
        contentImage.translatesAutoresizingMaskIntoConstraints = false
        contentImage.alignment = UIStackViewAlignment.center
        contentImage.spacing   = 5
        contentImage.clipsToBounds = true
        
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
        contentImageHeight.constant = 0
        timeLabelToImage.constant = 3
        
        retweetStackHeight.constant = 0
        avatarToRetweetStack.constant = 5
        retweetStack.isHidden = true
        
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
        
        if let avatarURL = tweet?.user?.profile_image_url {
            avatarImage.setImageWith(avatarURL)
        }
        
        if let nameString = tweet?.user?.name {
            nameLabel.text = nameString
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
            
            if let media = tweet.media {

                contentImage.isHidden = false
                contentImage.alpha = 1.0
                timeLabelToImage.constant = 15
                
                let stackWidth = contentImage.frame.width
                
                var photoCount = 0
                
                for mediaDictionary in media as! [NSDictionary] {
                    let media_url = mediaDictionary["media_url_https"] as! String
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
                    
                    if type == "photo" {
                        
                        contentImageHeight.constant = contentImage.frame.width * 0.6
                        
                        if let range = tmpContentString.range(of: display_url) {
                            tmpContentString = contentString.replacingCharacters(in: range, with: "")
                            // reset attributedString with displayed url
                            contentString = tmpContentString
                        }

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
        contentImage.addSubview(playButton)
    }

    @IBAction func menuButtonTapped(_ sender: UIButton) {
        self.delegate?.tweetCellMenuTapped!(cell: self, withId: tweet.id!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
