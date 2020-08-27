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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = FirebaseAuth.Auth.auth().currentUser
        Utils.setUser(user: currentUser)
        ref = Database.database().reference()
        ref.child("Users").child(currentUser.uid).observeSingleEvent(of: .value) { (dataSnapshot) in
            Utils.setUserData(userData: UserData(datasnapshot: dataSnapshot.value as! [String:AnyObject], uid: self.currentUser.uid))
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
