//
//  RatingViewController.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import AARatingBar
import Firebase

class RatingViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ratingBar: AARatingBar!
    @IBOutlet weak var tableView: UITableView!

    var post: Post?
    var ref: DatabaseReference!
    var ratings = 0
    var total: CGFloat = 0
    var rating: CGFloat = 0
    var reusableCell = "reusableCell"
    var ratingList: [Rating] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        if post != nil
        {
            if let image = post?.image
            {
                downloadImage(from: URL(string: image)!, imageView: self.imageView)
            }
            ref.child("Posts").child(post!.user!).child(post!.key!).child("Ratings").observe(.childAdded) { (dataSnapshot) in
                self.ratingList.append(Rating(datasnapshot: dataSnapshot.value as! [String: AnyObject], uid: dataSnapshot.key))
                self.ratings += 1
                self.total += ((dataSnapshot.value as! [String:AnyObject])["rating"] as! String).CGFloatValue()!
                self.rating = self.total / CGFloat(self.ratings)
                print(self.rating)
                self.ratingBar.value = self.rating
                self.tableView.reloadData()
            }
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

}

extension RatingViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ratingList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.reusableCell)

                if cell == nil
                {
                    cell = UITableViewCell(style: .subtitle, reuseIdentifier: self.reusableCell)
                }

                cell?.textLabel?.text = ratingList[indexPath.row].rating
                cell?.detailTextLabel?.text = ratingList[indexPath.row].userData?.name
        //        cell?.imageView?.image = UIImage(named: "profile_placeholder")
        //        if let imageview = cell?.imageView, let image = comments[indexPath.row].image
        //        {
        //            downloadImage(from: URL(string: image), imageView: imageview)
        //        }
                return cell!
    }
}
