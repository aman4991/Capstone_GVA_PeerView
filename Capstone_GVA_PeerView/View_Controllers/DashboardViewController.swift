//
//  DashboardViewController.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import Firebase

class DashboardViewController: ViewController {

    var currentUser: User!
    var ref: DatabaseReference!
    @IBOutlet weak var collectionView: UICollectionView!
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = FirebaseAuth.Auth.auth().currentUser
        Utils.setUser(user: currentUser)
        ref = Database.database().reference()
        ref.child("Users").child(currentUser.uid).observeSingleEvent(of: .value) { (dataSnapshot) in
            Utils.setUserData(userData: UserData(datasnapshot: dataSnapshot.value as! [String:AnyObject], uid: self.currentUser.uid))
        }
        ref.child("Followers").child(Utils.getUserUID()).observe(.childAdded) { (snapshot) in
            self.ref.child("Posts").child(snapshot.key).observe(.childAdded) { (dataSnapshot) in
                self.posts.append(Post(datasnapshot: dataSnapshot.value as! [String: AnyObject]))
            }
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
