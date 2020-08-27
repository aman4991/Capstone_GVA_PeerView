//
//  DashboardViewController.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class DashboardViewController: ViewController {

    var currentUser: User!
    var ref: DatabaseReference!
    @IBOutlet weak var collectionView: UICollectionView!
    var posts: [Post] = []
    let cellIdentifier = "cellIdentifier"
    var selectedPost: Post?
    var coordinates: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = FirebaseAuth.Auth.auth().currentUser
        Utils.setUser(user: currentUser)
        ref = Database.database().reference()
        registerCollectionViewCells()
        ref.child("Users").child(currentUser.uid).observeSingleEvent(of: .value) { (dataSnapshot) in
            Utils.setUserData(userData: UserData(datasnapshot: dataSnapshot.value as! [String:AnyObject], uid: self.currentUser.uid))
        }
        ref.child("Followers").child(Utils.getUserUID()).observe(.childAdded) { (snapshot) in
            self.ref.child("Posts").child(snapshot.key).observe(.childAdded) { (dataSnapshot) in
                self.posts.append(Post(datasnapshot: dataSnapshot.value as! [String: AnyObject]))
                self.posts.shuffle()
                self.collectionView.reloadData()
            }
        }
    }
    
    func registerCollectionViewCells()
    {
        let custom_collection_view_cell = UINib(nibName: "PostCollectionViewCell", bundle: nil)

        self.collectionView.register(custom_collection_view_cell, forCellWithReuseIdentifier: self.cellIdentifier)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pvc = segue.destination as? PostViewController
        {
            pvc.post = selectedPost
        }
        else if let mvc = segue.destination as? MapViewController
        {
            mvc.coorindates = self.coordinates
        }
    }
}

extension DashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate
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
        performSegue(withIdentifier: "dashToPost", sender: self)
    }
}

extension DashboardViewController: ToMove
{
    func moveToMap(coordinates: CLLocationCoordinate2D) {
        self.coordinates = coordinates
        performSegue(withIdentifier: "dashToMap", sender: self)
    }

}
