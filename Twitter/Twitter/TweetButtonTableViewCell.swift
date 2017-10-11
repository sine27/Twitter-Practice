//
//  TweetButtonTableViewCell.swift
//  Twitter
//
//  Created by Shayin Feng on 2/25/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

class TweetButtonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var replyButton: UIButton!
    
    @IBOutlet weak var retweetButton: UIButton!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var messageButton: UIButton!
    
    var tweet: TweetModel! {
        didSet {
            updateUIWithTweetDetails()
        }
    }


    var delegate: TweetButtonTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
        
    func updateUIWithTweetDetails () {
        if tweet.isUserRetweeted! {
            retweetButton.setImage(#imageLiteral(resourceName: "retweet-icon-green"), for: .normal)
        } else {
            retweetButton.setImage(#imageLiteral(resourceName: "retweet-icon-dark"), for: .normal)
        }
        if tweet.isUserFavorited! {
            favoriteButton.setImage(#imageLiteral(resourceName: "favor-icon-red"), for: .normal)
        } else {
            favoriteButton.setImage(#imageLiteral(resourceName: "favorited-icon-dark"), for: .normal)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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

    @IBAction func replyTapped(_ sender: UIButton) {
        delegate?.tweetCellReplyTapped!(cell: self)
    }
}
