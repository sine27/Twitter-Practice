//
//  MediaModel.swift
//  Twitter
//
//  Created by Shayin Feng on 10/9/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

class MediaModel: NSObject {
    
    var media_url: String!
    var url_should_be_replaced: String!
    var type: String!
    var mediaRatio: CGFloat!
    var video_info: NSDictionary!
    
    var dict: NSDictionary!
    
    init(dict: NSDictionary) {
        
        self.dict = dict
        
        media_url = dict["media_url"] as! String
        url_should_be_replaced = dict["url"] as! String
        
        // photo, animated_gif
        type = dict["type"] as! String
        
        let size = dict["sizes"] as! NSDictionary
        let large = size["large"] as! NSDictionary
        let h = large["h"] as! CGFloat
        let w = large["w"] as! CGFloat
        mediaRatio = h / w
        
        video_info = dict["video_info"] as? NSDictionary ?? [:]
    }
}
