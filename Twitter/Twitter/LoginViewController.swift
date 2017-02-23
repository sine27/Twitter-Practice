//
//  LoginViewController.swift
//  Twitter
//
//  Created by Shayin Feng on 2/20/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    
    let uiHelper = UIhelper()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 5
        
        self.uiHelper.stopActivityIndicator()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        self.uiHelper.activityIndicator(sender: self, style: UIActivityIndicatorViewStyle.white)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.loginProcess()
        }
    }
    
    func loginProcess () {
        if let client = TwitterClient.sharedInstance {
            client.fetchRequestTokenForLoggin(success: {
                print("Login Success")
                self.uiHelper.stopActivityIndicator()
                self.performSegue(withIdentifier: "loginToStart", sender: self)
            }, failure: { (error) in
                print("Login: Error >>> \(error.localizedDescription)")
                self.uiHelper.stopActivityIndicator()
            })
        }
    }
}
