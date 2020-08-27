//
//  ProfileVisitedViewController.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import Firebase

class ProfileVisitedViewController: UIViewController {

    var ref: DatabaseReference!
    var data: [ProfileVisited] = []
    var reusableCell = "reusableCell"

    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        ref.child("Profile_Visited").child(Utils.getUserUID()).observe(.childAdded) { (dataSnapshot) in
            self.data.append(ProfileVisited(datasnapshot: dataSnapshot.value as! [String: AnyObject], uid: dataSnapshot.key))
            self.tableview.reloadData()
        }
    }
}

extension ProfileVisitedViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.reusableCell)

        if cell == nil
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: self.reusableCell)
        }

        cell?.textLabel?.text = data[indexPath.row].userData?.name
        cell?.detailTextLabel?.text = data[indexPath.row].date
        if let imageview = cell?.imageView, let image = data[indexPath.row].userData?.image
        {
            downloadImage(from: URL(string: image), imageView: imageview)
        }
        return cell!
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
}
