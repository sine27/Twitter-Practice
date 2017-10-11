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
    
    @IBOutlet weak var cameraBuuton: UIBarButtonItem!
    
    @IBOutlet weak var imageStackView: UIStackView!
    
    var delegate: TweetTableViewDelegate?
    
    var tweet: TweetModel?
    
    var tweetOrg: TweetModel?
    
    var endpoint = -1
    
    var images: [UIImage] = [] {
        didSet {
            if imageStackView.arrangedSubviews.count >= 4 {
                if let imageView = imageStackView.arrangedSubviews[3] as? UIImageView, imageView.image == nil {
                    imageStackView.removeArrangedSubview(imageView)
                }
            }
        }
    }
    
    @IBAction func crossButtonTapped(_ sender: UIBarButtonItem) {
        
        let defaults = UserDefaults.standard
        
        inputTextView.resignFirstResponder()
        
        self.delegate?.getNewTweet(data: nil)
        
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
        var parameters: Any?
        
        if endpoint == 0 {
            parameters = ["status": inputTextView.text]
        } else if endpoint == 3 {
            if let id = tweet?.id {
                parameters = ["status": inputTextView.text, "in_reply_to_status_id": id]
                
            }
        }
        
        if images.count > 0 {
            var imageParam: Any?
            let urlEndPoint = "1.1/media/upload.json"
            //            var medias: [Any] = []
            //            for image in images {
            //                let data: Data = UIImagePNGRepresentation(image)!
            //                imageParam = ["media":String(data: data, encoding: String.Encoding.utf8) as String!]
            ////                imageParam["media_data"] = data.base64EncodedString()
            //            }
            let image = #imageLiteral(resourceName: "verified-account")
            let data: Data = UIImagePNGRepresentation(image)!
            imageParam = ["media_data":data.base64EncodedString()]
            
            if let client = TwitterClient.uploadClient {
                client.requestSerializer.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
                client.post(urlEndPoint, parameters: imageParam, progress: { (progress) in
                    debugPrint(progress)
                }, success: { (task, response) in
                    print("Media: Success")
                    self.postTweet(parameters)
                }, failure: { (task, error) in
                    debugPrint(task)
                    debugPrint(error)
                    UIhelper.alertMessage("Tweet", userMessage: error.localizedDescription, action: nil, sender: self)
                })
            }
        } else {
            postTweet(parameters)
        }
        
    }
    
    func postTweet(_ parameters: Any?) {
        if let client = TwitterClient.sharedInstance {
            client.post(TwitterClient.APIScheme.TweetStatusUpdateEndpoint, parameters: parameters as Any?, progress: { (progress) in
                print(progress)
            }, success: { (task, response) in
                print("Tweet: Success")
                
                let defaults = UserDefaults.standard
                defaults.set(nil, forKey: "twitter_saved_draft")
                
                if UserModel.currentUser!.statuses_count != nil {
                    UserModel.currentUser!.statuses_count! += 1
                }
                
                self.tweet = TweetModel(dictionary: response as! NSDictionary)
                self.presentingViewController!.dismiss(animated: true, completion: nil)
                self.delegate?.getNewTweet(data: self.tweet!)
            }, failure: { (task, error) in
                print("Tweet: Error >>> \(error)")
                UIhelper.alertMessage("Tweet", userMessage: error.localizedDescription, action: nil, sender: self)
            })
        }
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        if images.count < 4 {
            let alert = UIAlertController(title: "Photo", message: "", preferredStyle: .actionSheet)
            let openCameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
                let vc = UIImagePickerController()
                vc.delegate = self
                /// if camera available
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    vc.allowsEditing = true
                    vc.sourceType = .camera
                    vc.cameraCaptureMode = .photo
                    self.present(vc, animated: true, completion: nil)
                }
            }
            
            alert.addAction(openCameraAction)
            
            let openLibraryAction = UIAlertAction(title: "Library", style: .default) { (action) in
                let vc = UIImagePickerController()
                vc.delegate = self
                vc.allowsEditing = true
                vc.sourceType = .photoLibrary
                self.present(vc, animated: true, completion: nil)
            }
            alert.addAction(openLibraryAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func tapToRemove(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView {
            imageView.removeFromSuperview()
            imageStackView.addArrangedSubview(UIImageView(image: nil))
            if let index = images.index(of: imageView.image!) {
                images.remove(at: index)
                imageStackView.addArrangedSubview(UIImageView(image: nil))
            }
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
        
        let imageBackView = UIView()
        imageBackView.backgroundColor = .clear
        
        let defaults = UserDefaults.standard
        
        if let mentionUser = tweet?.user?.screen_name {
            var mentionString = "\(mentionUser) "
            var mentionStringOrg = ""
            if tweetOrg?.user?.screen_name != nil {
                mentionStringOrg = "\(tweetOrg!.user!.screen_name!) "
            }
            mentionString += mentionStringOrg
            inputTextView.text = mentionString
            wordCountLabel.text = "\(140 - mentionString.characters.count)"
            buttonColorChange(hidden: false)
            placeholderLabel.isHidden = true
        }
        else if let data = defaults.object(forKey: "twitter_saved_draft") as? String {
            inputTextView.text = data
            placeholderLabel.isHidden = true
            wordCountLabel.text = "\(140 - data.characters.count)"
            if data.characters.count > 140 {
                wordCountLabel.textColor = UIhelper.UIColorOption.red
            }
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
        } else if endpoint == 2 {
            tweetButton.isEnabled = false
            buttonColorChange(hidden: true)
            inputTextView.isEditable = false
            placeholderLabel.text = "Message Not Activated..."
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

extension PostViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("picker cancelled")
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            addImage(image)
        }
        else {
            print("Failed to load image")
        }
        picker.dismiss(animated: true, completion: nil)
    }

    // Add image to stack view
    func addImage(_ image: UIImage) {
        images.append(image)
        // let h = imageStackView.frame.height
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 60, height: 60))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapToRemove)))
        imageStackView.insertArrangedSubview(imageView, at: images.count - 1)
    }
}

