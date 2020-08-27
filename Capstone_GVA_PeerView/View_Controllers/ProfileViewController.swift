//
//  ProfileViewController.swift
//  Capstone_GVA_PeerView
//
//  Created by Aman on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class ProfileViewController: ViewController {
    
    @IBOutlet weak var settingsUIImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    var coordinates: CLLocationCoordinate2D?
    var selectedPost: Post?
    
    var ref: DatabaseReference!
    var currentUser: User!
    var storageRef: StorageReference!
    var userData: [String:String] = [:]
    var posts: [Post] = []
    let cellIdentifier = "reusecell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTapGestures()
        currentUser = Firebase.Auth.auth().currentUser!
        ref = Database.database().reference().child("Users").child(currentUser.uid)
        storageRef = Storage.storage().reference()
        getUserData()
        setImageView()
        registerCollectionViewCells()
        getUserPosts()
    }
    
    func registerCollectionViewCells()
    {
        let custom_collection_view_cell = UINib(nibName: "PostCollectionViewCell", bundle: nil)
        
        self.collectionView.register(custom_collection_view_cell, forCellWithReuseIdentifier: self.cellIdentifier)
    }
    
    func getUserPosts()
    {
        let ref1 = Database.database().reference().child("Posts").child(currentUser.uid)
        
        print(ref1)
        
        ref1.observe(.childAdded) { (dataSnapshot) in
            print("dataSnapshot: \(dataSnapshot)")
            if let map = dataSnapshot.value as? [String:AnyObject]
            {
                let post = Post(datasnapshot: map)
                print("Post: \(post.text)")
                self.posts.append(post)
            }
            self.collectionView.reloadData()
        }
    }
    
    func setTapGestures()
    {
        let settingTap = UITapGestureRecognizer(target: self, action: #selector(settingsTapped))
        settingsUIImageView.isUserInteractionEnabled = true
        settingsUIImageView.addGestureRecognizer(settingTap)
    }
    
    func setImageView()
    {
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }
    
    @objc func settingsTapped() {
        performSegue(withIdentifier: "toSettingsVC", sender: self)
    }
    
    func getUserData()
    {
        ref.observe(.value, with: { snapshot in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                if let value = snap.value as? String
                {
                    self.userData[key] = value
                }
            }
            if let image = self.userData["image"], let imageUrl = URL(string: image)
            {
                self.downloadImage(from: imageUrl)
            }
        })
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                self?.profileImageView.image = UIImage(data: data)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mvc = segue.destination as? MapViewController
        {
            mvc.coorindates = coordinates
        }
        else if let pvc = segue.destination as? PostViewController
        {
            pvc.post = selectedPost
        }
    }
    
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! PostCollectionViewCell
        cell.post = posts[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPost = posts[indexPath.row]
        performSegue(withIdentifier: "ownToPost", sender: self)
    }
}

extension ProfileViewController: ToMove
{
    func moveToMap(coordinates: CLLocationCoordinate2D) {
        self.coordinates = coordinates
        performSegue(withIdentifier: "profileToMap", sender: self)
    }
}
