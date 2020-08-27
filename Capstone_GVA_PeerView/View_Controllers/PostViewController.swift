//
//  PostViewController.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import AARatingBar
import Firebase

class PostViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var locationButton: UIImageView!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var commentsTextField: UITextField!
    @IBOutlet weak var ratingBar: AARatingBar!
    var currentUser: User!
    var ref: DatabaseReference!

    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = FirebaseAuth.Auth.auth().currentUser
        ref = Database.database().reference()
        setData()
    }
    
    func setData()
    {
        if let p = post
        {
            if let text = p.text
            {
                textview.text = text
            }
            if let image = p.image
            {
                downloadImage(from: URL(string: image)!)
            }
            if let rating = p.image as? Double
            {
                ratingBar.value = CGFloat(rating)
            }
            if let _ = p.lat, let _ = p.lng
            {

            }
            else
            {
                locationButton.isHidden = true
            }
        }
    }


    @IBAction func locationClicked(_ sender: Any) {
        
    }

    @IBAction func commentClicked(_ sender: Any) {
        if let comment = commentsTextField.text
        {
            dump(post)
            let ref = self.ref.child("Posts").child(currentUser.uid).child(post!.key!).child("Comments").childByAutoId()
            let key = ref.key
            var data: [String: String] = [:]
            data["uid"] = Utils.getUserData()?.uid
            data["name"] = Utils.getUserData()?.name
            data["image"] = Utils.getUserData()?.image
            data["key"] = key
            ref.updateChildValues(data)
            data["comment"] = comment

        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }


    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() { [weak self] in
                self?.imageView.image = UIImage(data: data)
            }
        }
    }

}
