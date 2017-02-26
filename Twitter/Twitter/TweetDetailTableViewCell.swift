//
//  TweetDetailTableViewCell.swift
//  Twitter
//
//  Created by Shayin Feng on 2/25/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import ActiveLabel

class TweetDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var screenLabel: UILabel!
    
    @IBOutlet weak var contentLabel: ActiveLabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    //@IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var contentImage: UIStackView!
    
    @IBOutlet weak var contentImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var timeLabelToImage: NSLayoutConstraint!
    
    var tweet: TweetModel! {
        didSet {
            updateUIWithTweetDetails()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = 5
        avatarImage.image = #imageLiteral(resourceName: "noImage")
        contentImage.layer.masksToBounds = true
        contentImage.layer.cornerRadius = 5
        timeLabelToImage.constant = 3
        
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
    }
    
    override func prepareForReuse() {
        contentImageHeight.constant = 0
        timeLabelToImage.constant = 3
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
            dateFormatter.dateFormat = "MM/dd/yyyy, HH:mm"
            timeLabel.text = dateFormatter.string(from: timeCreated)
        }
        
        if var contentString = tweet?.text {
            
            var tmpContentString = contentString
            
            if let media = tweet.media {
                
                var stackHeight: CGFloat = 0
                
                contentImage.isHidden = false
                contentImage.alpha = 1.0
                timeLabelToImage.constant = 15
                let stackWidth = contentImage.frame.width
                
                for mediaDictionary in media as! [NSDictionary] {
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
                        
                        // calculate image width
                        let sizeDic = mediaDictionary["sizes"] as! NSDictionary
                        let largeSizeDic = sizeDic["large"] as! NSDictionary
                        let height = largeSizeDic["h"] as! CGFloat
                        let width = largeSizeDic["w"] as! CGFloat
                        let ratio = height / width
                        
                        let imageView = UIImageView()
                        imageView.heightAnchor.constraint(equalToConstant: stackWidth * ratio).isActive = true
                        imageView.widthAnchor.constraint(equalToConstant: stackWidth).isActive = true
                        
                        let imageRequest = URLRequest(url: URL(string: media_url)!)
                        imageView.setImageWith(imageRequest, placeholderImage: #imageLiteral(resourceName: "loadingImage"), success: { (request, response, image) in
                            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                                imageView.image = image
                            })
                        })
                        stackHeight += stackWidth * ratio
                        print("\(stackWidth * ratio)     \(stackHeight)")
                        contentImage.addArrangedSubview(imageView)
                    }
                }
                contentImage.translatesAutoresizingMaskIntoConstraints = false;
                contentImage.alignment = UIStackViewAlignment.center
                contentImage.spacing   = 10.0
                contentImageHeight.constant = stackHeight
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
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        
    }
    
    
}
