//
//  PostViewController.swift
//  Twitter
//
//  Created by Shayin Feng on 2/24/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

class PostViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var inputTextView: UITextView!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var tweetButton: UIButton!
    
    @IBOutlet weak var wordCountLabel: UILabel!
    
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBOutlet weak var buttomHeight: NSLayoutConstraint!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var delegate: TweetTableViewDelegate?
    
    var tweet: TweetModel?
    
    var endpoint = -1
    
    @IBAction func crossButtonTapped(_ sender: UIBarButtonItem) {
        
        let defaults = UserDefaults.standard
        
        inputTextView.resignFirstResponder()
        
        if inputTextView.text != "" {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                defaults.set(nil, forKey: "twitter_saved_draft")
                self.endpoint = -1
                self.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(deleteAction)
            
            // save to draft (user default)
            let draftAction = UIAlertAction(title: "Save draft", style: .default) { (action) in
                let data = self.inputTextView.text
                
                defaults.set(data, forKey: "twitter_saved_draft")
                self.endpoint = -1
                self.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(draftAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.inputTextView.becomeFirstResponder()
            }
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            endpoint = -1
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func tweetButtonTapped(_ sender: Any) {
        inputTextView.resignFirstResponder()
        
        if let client = TwitterClient.sharedInstance {
            client.post(TwitterClient.APIScheme.TweetStatusUpdateEndpoint, parameters: ["status": inputTextView.text], progress: { (progress) in
                print(progress)
            }, success: { (task, response) in
                print("Tweet: Success")
                let defaults = UserDefaults.standard
                defaults.set(nil, forKey: "twitter_saved_draft")
                self.tweet = TweetModel(dictionary: response as! NSDictionary)
                self.presentingViewController!.dismiss(animated: true, completion: nil)
                self.delegate?.getNewTweet(data: self.tweet!)
            }, failure: { (task, error) in
                print("Tweet: Error >>> \(error)")
                UIhelper.alertMessage("Tweet", userMessage: error.localizedDescription, action: nil, sender: self)
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbar.layer.borderWidth = 0.2
        toolbar.layer.borderColor = UIhelper.UIColorOption.gray.cgColor
        
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = 5
        
        tweetButton.layer.borderWidth = 0.8
        tweetButton.layer.borderColor = UIhelper.UIColorOption.gray.cgColor
        tweetButton.layer.masksToBounds = true
        tweetButton.layer.cornerRadius = 7
        tweetButton.isEnabled = false

        inputTextView.becomeFirstResponder()
        
        wordCountLabel.text = "140"
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: "twitter_saved_draft") as? String {
            inputTextView.text = data
            placeholderLabel.isHidden = true
            wordCountLabel.text = "\(140 - data.characters.count)"
            tweetButton.isEnabled = true
            buttonColorChange(hidden: false)
        }
        
        avatarImage.image = #imageLiteral(resourceName: "noImage")
        
        if let imageUrl = UserModel.currentUser?.profile_image_url_https {
            avatarImage.setImageWith((imageUrl), placeholderImage: #imageLiteral(resourceName: "noImage"))
        }
        
        if endpoint == -1 {
            tweetButton.isEnabled = false
            buttonColorChange(hidden: true)
            inputTextView.isEditable = false
            placeholderLabel.text = "Unkown Sender..."
        } else if endpoint == 1 {
            tweetButton.isEnabled = false
            buttonColorChange(hidden: true)
            inputTextView.isEditable = false
            placeholderLabel.text = "Reply Not Activated..."
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.6, animations: {
                self.view.layoutIfNeeded()
                self.buttomHeight.constant = keyboardSize.height
            })
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            UIView.animate(withDuration: 0.6, animations: {
                self.buttomHeight.constant = 0
            })
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.characters.count
        if count <= 0 {
            placeholderLabel.isHidden = false
            buttonColorChange(hidden: true)
        } else if count > 0 {
            buttonColorChange(hidden: false)
            placeholderLabel.isHidden = true
        }
        if count > 140 {
            buttonColorChange(hidden: true)
            wordCountLabel.textColor = UIhelper.UIColorOption.red
        } else {
            wordCountLabel.textColor = UIhelper.UIColorOption.twitterGray
        }
        wordCountLabel.text = "\(140 - count)"
    }
    
    func buttonColorChange (hidden: Bool) {
        if hidden {
            tweetButton.isEnabled = false
            tweetButton.setTitleColor(UIhelper.UIColorOption.gray, for: .normal)
            tweetButton.backgroundColor = UIColor.white
            tweetButton.layer.borderWidth = 1
            tweetButton.layer.borderColor = UIhelper.UIColorOption.gray.cgColor
        } else {
            tweetButton.isEnabled = true
            tweetButton.setTitleColor(UIColor.white, for: .normal)
            tweetButton.backgroundColor = UIhelper.UIColorOption.twitterBlue
            tweetButton.layer.borderWidth = 1
            tweetButton.layer.borderColor = UIhelper.UIColorOption.twitterBlue.cgColor
        }
    }

}
