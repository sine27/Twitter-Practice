//
//  ProfileHeaderTableViewCell.swift
//  Twitter
//
//  Created by Shayin Feng on 3/3/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

class ProfileHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerSegmentedController: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        headerSegmentedController.selectedSegmentIndex = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onSegmentedControllerChanged(_ sender: UISegmentedControl) {
    }
}
