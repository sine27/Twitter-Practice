//
//  TwitterTableViewCell.swift
//  Twitter
//
//  Created by Shayin Feng on 2/21/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import AFNetworking

class TwitterTableViewCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var userAvatar: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var timeCreateLabel: UILabel!
    
    @IBOutlet weak var menuButton: UIButton!
    
    // @IBOutlet weak var contentLabel: UITextView!
    @IBOutlet weak var contentLabel: UITextView!
    
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
    
    let client = TwitterClient.sharedInstance!
    
    var tweet : TweetModel! {
        didSet {
            updateUIWithTweetDetails()
        }
    }
    
    var userName : String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userAvatar.layer.masksToBounds = true
        userAvatar.layer.cornerRadius = 5
        userAvatar.image = UIImage(named: "noImage")
        contentLabel.delegate = self
        contentImage.layer.masksToBounds = true
        contentImage.layer.cornerRadius = 5
        
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
        userName = nil
        contentImage.isHidden = true
        retweetStack.isHidden = true
        stackToContentImage.constant = 5
        contentImageHeight.constant = 0
        retweetLabelHeight.constant = 0
        avatarToRetweeted.constant = 5
    }
    
    private func updateUIWithTweetDetails () {
        
        if userName != nil {
            if userName == (UserModel.currentUser!.name) {
                retweetLabel.text = " You Retweeted"
            } else {
                retweetLabel.text = " \(userName!) Retweeted"
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
        
        if let contentString = tweet?.text {
            
            var attributedString = NSMutableAttributedString(string: contentString)
            
            var newContentString = ""
            
            var tmpContentString = contentString
            
            if let urls = tweet.urls {
                for item in urls {
                    if let urlDictionary = item as? NSDictionary {
                        let display_url = urlDictionary["display_url"] as! String
                        let url = urlDictionary["url"] as! String
                        
                        // find the range in contentString where contains url
                        if let range = tmpContentString.range(of: url) {
                            // replace url to displayed url
                            newContentString = tmpContentString.replacingCharacters(in: range, with: display_url)
                            // reset attributedString with displayed url
                            tmpContentString = newContentString
                        }
                    }
                }
            }
            
            if let media = tweet.media {
                if let mediaDictionary = media[0] as? NSDictionary {
                    let media_url = mediaDictionary["media_url_https"] as! String
                    let display_url = mediaDictionary["url"] as! String
                    // find the range in contentString where contains url
                    let type = mediaDictionary["type"] as! String
                    if type == "photo" {
                        if let range = tmpContentString.range(of: display_url) {
                            newContentString = tmpContentString.replacingCharacters(in: range, with: "")
                            // reset attributedString with displayed url
                            tmpContentString = newContentString
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
            attributedString = NSMutableAttributedString(string: tmpContentString)
            // *** Create instance of `NSMutableParagraphStyle`
            let paragraphStyle = NSMutableParagraphStyle()
            // *** set LineSpacing property in points ***
            paragraphStyle.lineSpacing = 2
            // *** Apply attribute to string ***
            attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            // set the font size
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 14), range: NSMakeRange(0, attributedString.length))
            // set contentLabel
            contentLabel.attributedText = attributedString
        } else {
            contentLabel.text = ""
        }
        
        numReplyLabel.setTitle("", for: .normal)
        
        if let numRetweet = tweet?.retweetCount, numRetweet > 0 {
            numRetwitteLabel.setTitle(numRetweet.displayCountWithFormat(), for: .normal)
        } else {
            numRetwitteLabel.setTitle("", for: .normal)
        }
        
        if let numFavorite = tweet?.favoriteCount, numFavorite > 0 {
            numFavoriteLabel.setTitle(numFavorite.displayCountWithFormat(), for: .normal)
        } else {
            numFavoriteLabel.setTitle("", for: .normal)
        }
    }
    
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
        
        if tweet.isUserRetweeted! {
            endpoint = TwitterClient.APIScheme.RetweetStatusEndpoint
        } else {
            endpoint = TwitterClient.APIScheme.UnretweetStatusEndpoint
        }
        
        client.postRequest(endpoint: endpoint!, parameters: ["id" : tweet.id!], completion: { (response, error) in
            
            if let error = error {
                print("favorite: Error >>> \(error.localizedDescription)")
            } else {
                print("favorite: success")
                if self.tweet.isUserRetweeted! {
                    self.reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon-dark"), for: .normal)
                    self.numRetwitteLabel.setButtonTitleColor(option: .gray)
                    self.tweet.isUserRetweeted = false
                } else {
                    self.reTwitteButton.setImage(#imageLiteral(resourceName: "retweet-icon-green"), for: .normal)
                    self.numRetwitteLabel.setButtonTitleColor(option: .green)
                    self.tweet.isUserRetweeted = true
                }
            }
        })
    }
    
    @IBAction func favoritedTapped(_ sender: UIButton) {
        var endpoint : String?
        
        if tweet.isUserFavorited! {
            endpoint = TwitterClient.APIScheme.FavoriteDestroyEndpoint
        } else {
            endpoint = TwitterClient.APIScheme.FavoriteCreateEndpoint
        }
        
        client.postRequest(endpoint: endpoint!, parameters: ["id" : tweet.id!], completion: { (response, error) in
            
            if let error = error {
                print("retweet: Error >>> \(error.localizedDescription)")
            } else {
                print("retweet: success")
                if self.tweet.isUserFavorited! {
                    self.favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon"), for: .normal)
                    self.numFavoriteLabel.setButtonTitleColor(option: .gray)
                    self.tweet.isUserFavorited = false
                } else {
                    self.favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon-red"), for: .normal)
                    self.numFavoriteLabel.setButtonTitleColor(option: .red)
                    self.tweet.isUserFavorited = true
                }
            }
        })
    }

    @IBAction func messageTapped(_ sender: UIButton) {
        
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
