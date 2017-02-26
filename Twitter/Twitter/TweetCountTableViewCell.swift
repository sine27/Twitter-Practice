//
//  TweetCountTableViewCell.swift
//  Twitter
//
//  Created by Shayin Feng on 2/25/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

class TweetCountTableViewCell: UITableViewCell {
    
    @IBOutlet weak var numRetweetLabel: UILabel!
    
    @IBOutlet weak var numFavoriteLabel: UILabel!
    
    var tweet: TweetModel! {
        didSet {
            numRetweetLabel.text = tweet.retweetCount!.displayCountWithFormat()
            numFavoriteLabel.text = tweet.favoriteCount!.displayCountWithFormat()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        numRetweetLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
