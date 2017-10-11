//
//  OtherHelper.swift
//  Twitter
//
//  Created by Shayin Feng on 2/21/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

class OtherHelper: NSObject {
    class func alertWithAction(_ title: String, message: String, image: UIImage? = nil, numActions: Int, actionTitles: [String], actionStyles:  [UIAlertActionStyle], actions: [((UIAlertAction) -> Void)?], sender: UIViewController)
    {
        guard numActions == actionTitles.count, numActions == actions.count else {
            debugPrint("alertWithAction: Number of actions does not match")
            return
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for i in 0..<numActions {
            alert.addAction(UIAlertAction(title: actionTitles[i], style: actionStyles[i], handler: actions[i]))
        }
        sender.present(alert, animated: true, completion: nil)
    }
}

// UIImagePickerControllerDelegate

//
// func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
// // Get the image captured by the UIImagePickerController
// // let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
// let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
// 
// // Do something with the images (based on your use case)
// updateAvatar(image: editedImage)
// 
// // Dismiss UIImagePickerController to go back to your original view controller
// dismiss(animated: true, completion: nil)
// }
// 
// func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
// picker.dismiss(animated: true, completion: nil)
// }
// 
// func addImage(_ sender: UIImage) {
// let vc = UIImagePickerController()
// vc.delegate = self
// vc.allowsEditing = true
// vc.sourceType = .photoLibrary
// present(vc, animated: true, completion: nil)
// }
 
