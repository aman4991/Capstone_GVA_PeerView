//
//  UserProfileViewController.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sendRequestButton: UIButton!
    var userData: UserData?
    var ref: DatabaseReference!
    var cellIdentifier = "cellIdentifier"
    var coordinates: CLLocationCoordinate2D?
    var ltitle: String?
    
    var posts: [Post] = []
    var selectedPost: Post?
    var alreadyFollowed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        setImageView()
        registerCollectionViewCells()
        if userData != nil
        {
            var map = Utils.getUserData()?.getUserDataMap()
            map!["date"] = getDate()
            ref.child("Profile_Visited").child(userData!.uid).child(Utils.getUserUID()).setValue(map)
            nameLabel.text = userData?.name
            statusLabel.text = userData?.status
            if let image = userData!.image
            {
                downloadImage(from: URL(string: image), imageView: self.imageView)
            }
            ref.child("Followers").child(userData!.uid).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                if dataSnapshot.hasChild(Utils.getUserUID())
                {
                    self.alreadyFollowed = true
                    self.sendRequestButton.setTitle("Unfollow", for: .normal)
                    self.getPosts()
                }
                else
                {
                    self.collectionView.isHidden = true
                }
            })
        }
    }
    
    @IBAction func sendRequestTapped(_ sender: Any) {
        if alreadyFollowed
        {
            ref.child("Followers").child(userData!.uid).child(Utils.getUserUID()).removeValue()
            ref.child("Followers").child(Utils.getUserUID()).child(userData!.uid).removeValue()
            self.sendRequestButton.setTitle("Send Request", for: .normal)
            self.collectionView.isHidden = true
        }
        else
        {
            ref.child("Follow Requests").child(userData!.uid).child(Utils.getUserUID()).setValue(Utils.getUserData()!.getUserDataMap())
            sendRequestButton.setTitle("Request Sent", for: .normal)
        }
    }
    
    func registerCollectionViewCells()
    {
        let custom_collection_view_cell = UINib(nibName: "PostCollectionViewCell", bundle: nil)
        
        self.collectionView.register(custom_collection_view_cell, forCellWithReuseIdentifier: self.cellIdentifier)
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
    
    func getPosts()
    {
        ref.child("Posts").child(userData!.uid).observe(.childAdded) { (datasnapshot) in
            dump(datasnapshot)
            self.posts.append(Post(datasnapshot: datasnapshot.value as! [String: AnyObject]))
            self.collectionView.reloadData()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mvc = segue.destination as? MapViewController
        {
            mvc.coorindates = self.coordinates
            mvc.locationTitle = self.ltitle
        }
        if let pvc = segue.destination as? PostViewController
        {
            pvc.post = selectedPost
        }
    }
    
    func setImageView()
    {
        imageView.layer.borderWidth = 1.0
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }
    
    func getDate() -> String
    {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
}

extension UserProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate
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
        performSegue(withIdentifier: "profileToPost", sender: self)
    }
    
}

extension UserProfileViewController: ToMove
{
    func moveToMap(coordinates: CLLocationCoordinate2D, title: String) {
        self.coordinates = coordinates
        self.ltitle = title
        performSegue(withIdentifier: "userProfileToMap", sender: self)
    }
}
