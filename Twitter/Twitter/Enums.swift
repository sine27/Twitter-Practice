//
//  Enums.swift
//  Twitter
//
//  Created by Shayin Feng on 10/9/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import Foundation

// set button title color for favorited, retweeted
enum ButtonTitleColorOption: Int {
    case green = 0, gray, red, blue, yellow
}

enum LoadType {
    case getNew, loadMore, pullRefresh
}
