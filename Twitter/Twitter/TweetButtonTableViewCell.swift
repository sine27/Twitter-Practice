//
//  TweetButtonTableViewCell.swift
//  Twitter
//
//  Created by Shayin Feng on 2/25/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

@objc protocol TweetButtonTableViewCellDelegate: class {
    @objc optional func tweetCellFavoritedTapped(cell: TweetButtonTableViewCell, isFavorited: Bool)
    @objc optional func tweetCellRetweetTapped(cell: TweetButtonTableViewCell, isRetweeted: Bool)
}

class TweetButtonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var replyButton: UIButton!
    
    @IBOutlet weak var retweetButton: UIButton!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var messageButton: UIButton!
    
    var tweet: TweetModel!

    var delegate: TweetButtonTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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

}
