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
                self.ratings += 1
                self.total += ((dataSnapshot.value as! [String:AnyObject])["rating"] as! String).CGFloatValue()!
                self.rating = self.total / CGFloat(self.ratings)
                print(self.rating)
                self.ratingBar.value = self.rating
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

}
