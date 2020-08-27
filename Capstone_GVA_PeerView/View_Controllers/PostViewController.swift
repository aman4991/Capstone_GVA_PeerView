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
    var rating: CGFloat = 0
    var total: CGFloat = 0
    var ratings: Int = 0
    @IBOutlet weak var deleteBtn: UIBarButtonItem!
    @IBOutlet weak var locationBtn: UIBarButtonItem!

    var delegate: ProfileViewController?
    
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = FirebaseAuth.Auth.auth().currentUser
        ref = Database.database().reference()
        ref.child("Posts").child(post!.user!).child(post!.key!).child("Comments").observe(.childAdded) { (dataSnapshot) in
            self.comments.append(Comment(datasnapshot: dataSnapshot.value as! [String: AnyObject]))
            self.tableview.reloadData()
        }
        if post?.user == Utils.getUserUID()
        {
            ref.child("Posts").child(post!.user!).child(post!.key!).child("Ratings").observe(.childAdded) { (dataSnapshot) in
                self.ratings += 1
                self.total += ((dataSnapshot.value as! [String:AnyObject])["rating"] as! String).CGFloatValue()!
                self.rating = self.total / CGFloat(self.ratings)
                print(self.rating)
                self.ratingBar.value = self.rating
            }
        }
        else
        {
            ref.child("Posts").child(post!.user!).child(post!.key!).child("Ratings").child(Utils.getUserUID()).observeSingleEvent(of: .value) { (dataSnapshot) in
                if let map = dataSnapshot.value as? [String:AnyObject]
                {
                    if let r = map["rating"] as? String
                    {
                        self.ratingBar.value = r.CGFloatValue() ?? 0
                    }
                }
            }
        }
        if post?.user == currentUser.uid
        {
            ratingBar.isEnabled = false
            setTapGestures()
        }
        if post?.lat == nil, post?.user != currentUser.uid
        {
            self.navigationItem.rightBarButtonItems = nil
        }
        else if post?.lat == nil, post?.user == currentUser.uid
        {
            self.navigationItem.rightBarButtonItems = [deleteBtn]
        }
        else if post?.lat != nil, post?.user != currentUser.uid
        {
            self.navigationItem.rightBarButtonItems = [locationBtn]
        }
        setData()
        ratingBar.ratingDidChange = ratingValue(_:)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        commentsTextField.resignFirstResponder()
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        ref.child("Posts").child(currentUser.uid).child(post!.key!).removeValue()
        delegate?.removePost(post: post!)
        self.navigationController?.popViewController(animated: true)
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
                let url = URL(string: image)!
                downloadImage(from: url)
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
    
    func setTapGestures()
    {
        let ratingBarTap = UITapGestureRecognizer(target: self, action: #selector(ratingBarTapped))
        ratingBar.isUserInteractionEnabled = true
        ratingBar.addGestureRecognizer(ratingBarTap)
    }
    
    
    @objc func ratingBarTapped()
    {
        performSegue(withIdentifier: "postToPostRating", sender: self)
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
    
    
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() { [weak self] in
                let image = UIImage(data: data)!
                self?.imageView.isHidden = false
                self?.imageView.image = image
                //                dump(self?.imageView)
            }
        }
    }
    
    func downloadImage(from url: URL, imageview: UIImageView) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() { [weak self] in
                imageview.image = UIImage(data: data)
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
            mvc.locationTitle = post?.ltitle
        }
        else if let rvc = segue.destination as? RatingViewController
        {
            rvc.post = self.post
        }
    }
    
    func ratingValue(_ rating: CGFloat) -> Void
    {
        print("rating: \(rating)")
        if rating != CGFloat(0)
        {
            var map = Utils.getUserData()?.getUserDataMap()
            map!["rating"] = "\(rating)"
            ref.child("Posts").child(post!.user!).child(post!.key!).child("Ratings").child(Utils.getUserUID()).setValue(map)
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
        cell?.imageView?.image = UIImage(named: "profile_placeholder")
        if let imageview = cell?.imageView, let image = comments[indexPath.row].image
        {
            downloadImage(from: URL(string: image)!, imageview: imageview)
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
    
    func CGFloatValue() -> CGFloat? {
        guard let doubleValue = Double(self) else {
            return nil
        }
        
        return CGFloat(doubleValue)
    }
}

extension PostViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
