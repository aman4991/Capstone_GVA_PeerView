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
    var ratingMap: [String:[Rating]] = [:]
    var sorting = 0
    
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
//                self.ratingList.append(Rating(datasnapshot: dataSnapshot.value as! [String: AnyObject], uid: dataSnapshot.key))
                let newRating = Rating(datasnapshot: dataSnapshot.value as! [String: AnyObject], uid: dataSnapshot.key)
                if var ar = self.ratingMap["No Order"]
                {
                    ar.append(newRating)
                    self.ratingMap["No Order"] = ar
                }
                else
                {
                    self.ratingMap["No Order"] = [newRating]
                }
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
    
    @IBAction func sorted(_ sender: Any) {
        if sorting == 0
        {
            var newMap: [String:[Rating]] = [:]
            for key in ratingMap.keys
            {
                for r in ratingMap[key]!
                {
                    if var ar = newMap[r.userData!.gender!]
                    {
                        ar.append(r)
                        newMap[r.userData!.gender!] = ar
                    }
                    else
                    {
                        newMap[r.userData!.gender!] = [r]
                    }
                }
            }
            ratingMap = newMap
            dump(newMap)
            sorting = 1
            tableView.reloadData()
        }
        else if sorting == 1
        {
            var newMap: [String:[Rating]] = [:]
            for key in ratingMap.keys
            {
                for r in ratingMap[key]!
                {
                    if var ar = newMap[r.userData!.age!]
                    {
                        ar.append(r)
                        newMap[r.userData!.age!] = ar
                    }
                    else
                    {
                        newMap[r.userData!.age!] = [r]
                    }
                }
            }
            ratingMap = newMap
            dump(newMap)
            sorting = 2
            tableView.reloadData()
        }
        else
        {
            var newMap: [String:[Rating]] = [:]
            for key in ratingMap.keys
            {
                for r in ratingMap[key]!
                {
                    if var ar = newMap["No Order"]
                    {
                        ar.append(r)
                        newMap["No Order"] = ar
                    }
                    else
                    {
                        newMap["No Order"] = [r]
                    }
                }
            }
            ratingMap = newMap
            dump(newMap)
            sorting = 0
            tableView.reloadData()
        }
    }

}

extension RatingViewController: UITableViewDelegate, UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ratingMap.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ratingMap.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(ratingMap.keys)[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.reusableCell)

                if cell == nil
                {
                    cell = UITableViewCell(style: .subtitle, reuseIdentifier: self.reusableCell)
                }

                cell?.textLabel?.text = ratingMap[Array(ratingMap.keys)[indexPath.section]]![indexPath.row].rating
                cell?.detailTextLabel?.text = ratingMap[Array(ratingMap.keys)[indexPath.section]]![indexPath.row].userData?.name
        //        cell?.imageView?.image = UIImage(named: "profile_placeholder")
        //        if let imageview = cell?.imageView, let image = comments[indexPath.row].image
        //        {
        //            downloadImage(from: URL(string: image), imageView: imageview)
        //        }
                return cell!
    }
}
