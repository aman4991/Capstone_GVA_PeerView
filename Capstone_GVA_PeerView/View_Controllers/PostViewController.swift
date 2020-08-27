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
import MapKit

class PostViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var locationButton: UIImageView!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var commentsTextField: UITextField!
    @IBOutlet weak var ratingBar: AARatingBar!
    var currentUser: User!
    var ref: DatabaseReference!
    var comments: [Comment] = []
    let reusableCell = "reusableCell"

    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = FirebaseAuth.Auth.auth().currentUser
        ref = Database.database().reference()
        ref.child("Posts").child(post!.user!).child(post!.key!).child("Comments").observe(.childAdded) { (dataSnapshot) in
            self.comments.append(Comment(datasnapshot: dataSnapshot.value as! [String: AnyObject]))
            self.tableview.reloadData()
        }
        if post?.user == currentUser.uid
        {
            ratingBar.isEnabled = false
            print("rating disabled")
        }
        if post?.lat == nil
        {
            self.navigationItem.rightBarButtonItems = nil
        }
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
                downloadImage(from: URL(string: image)!, imageView: self.imageView)
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
        performSegue(withIdentifier: "postToMap", sender: self)
    }

    @IBAction func commentClicked(_ sender: Any) {
        if let comment = commentsTextField.text
        {
            dump(post)
            let ref = self.ref.child("Posts").child(post!.user!).child(post!.key!).child("Comments").childByAutoId()
            let key = ref.key
            var data: [String: String] = [:]
            data["uid"] = Utils.getUserData()?.uid
            data["name"] = Utils.getUserData()?.name
            data["image"] = Utils.getUserData()?.image
            data["key"] = key
            ref.updateChildValues(data)
            data["comment"] = comment
            commentsTextField.text = ""
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }


    func downloadImage(from url: URL?, imageView: UIImageView) {
        if url != nil
        {
            getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? url!.lastPathComponent)
                DispatchQueue.main.async() { [weak self] in
                    imageView.image = UIImage(data: data)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mvc = segue.destination as? MapViewController
        {
            mvc.coorindates = CLLocationCoordinate2D(latitude: post!.lat!.toDouble()!, longitude: post!.lng!.toDouble()!)
        }
    }
}

extension PostViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.reusableCell)

        if cell == nil
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: self.reusableCell)
        }

        cell?.textLabel?.text = comments[indexPath.row].comment
        cell?.detailTextLabel?.text = comments[indexPath.row].name
        if let imageview = cell?.imageView, let image = comments[indexPath.row].image
        {
            downloadImage(from: URL(string: image), imageView: imageview)
        }
        else
        {
            cell?.imageView?.image = UIImage(named: "profile_placeholder")
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}
