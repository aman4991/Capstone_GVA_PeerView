//
//  SearchViewController.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController {

    var currentUser: User!
    var ref: DatabaseReference!
    var userData: [UserData] = []
    var users: [UserData] = []
    let reusableCell = "reusableCell"
    @IBOutlet weak var tableview: UITableView!
    var selectedUser: UserData?

    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = FirebaseAuth.Auth.auth().currentUser
        ref = Database.database().reference()
        ref.child("Users").observe(.childAdded) { (dataSnapshot) in
            self.userData.append(UserData(datasnapshot: dataSnapshot.value as! [String: AnyObject], uid: dataSnapshot.key))
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let upvc = segue.destination as? UserProfileViewController
        {
            upvc.userData = selectedUser
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.reusableCell)

        if cell == nil
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: self.reusableCell)
        }

        cell?.textLabel?.text = users[indexPath.row].name
        cell?.detailTextLabel?.text = users[indexPath.row].status
        if let imageview = cell?.imageView, let image = users[indexPath.row].image
        {
            downloadImage(from: URL(string: image), imageView: imageview)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = users[indexPath.row]
        performSegue(withIdentifier: "userClick", sender: self)
    }

}

extension SearchViewController: UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        users = []
        if searchText == ""
        {
            tableview.reloadData()
            return
        }
        for ud in self.userData
        {
            if ud.name.lowercased().contains(searchText.lowercased())
            {
                users.append(ud)
            }
        }
        tableview.reloadData()
    }
}
