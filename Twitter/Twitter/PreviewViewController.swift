//
//  PreviewViewController.swift
//  Twitter
//
//  Created by Shayin Feng on 2/26/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imgScrollView: UIScrollView!
    
    var image = UIImage()
    
    var delegate: TweetTableViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        
        imgScrollView.delegate = self

        // Do any additional setup after loading the view.
        
        imgScrollView.minimumZoomScale = 1.0
        imgScrollView.maximumZoomScale = 3.0
        
        self.automaticallyAdjustsScrollViewInsets = false
        imgScrollView.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
