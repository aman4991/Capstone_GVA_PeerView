//
//  FollowRequestsViewController.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import Firebase

class FollowRequestsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var userData: [UserData] = []
    var ref: DatabaseReference!
    let cellIdentifier = "cellIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        registerCell()
        ref.child("Follow Requests").child(Utils.getUserUID()).observe(.childAdded) { (dataSnapshot) in
            self.userData.append(UserData(datasnapshot: dataSnapshot.value as! [String: AnyObject], uid: dataSnapshot.key))
            self.tableView.reloadData()
        }
    }

    func registerCell()
    {
        let custom_cell = UINib(nibName: "RequestTableViewCell", bundle: nil)
        tableView.register(custom_cell, forCellReuseIdentifier: self.cellIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
}

extension FollowRequestsViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) as? RequestTableViewCell

        if cell == nil
        {
            cell = RequestTableViewCell()
        }
        cell?.userData = self.userData[indexPath.row]
        cell?.index = indexPath
        cell?.delegate = self
        return cell!
    }
}

extension FollowRequestsViewController: FollowRequestOperations
{
    func removeRequest(at: IndexPath) {
        userData.remove(at: at.row)
        tableView.deleteRows(at: [at], with: .left)
    }
}
