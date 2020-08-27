//
//  RequestTableViewCell.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import Firebase

class RequestTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var userData: UserData?
    var ref: DatabaseReference!

    override func awakeFromNib() {
        super.awakeFromNib()
        ref = Database.database().reference()
        if userData != nil
        {
            nameLabel.text = userData!.name
            if let image = userData?.image
            {
                downloadImage(from: URL(string: image), imageView: profileImageView)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBAction func acceptButton(_ sender: Any) {
        ref.child("Followers").child(Utils.getUserUID()).child(userData!.uid).setValue(userData?.getUserDataMap())
        ref.child("Follow Requests").child(Utils.getUserUID()).child(userData!.uid).removeValue()
    }
    @IBAction func declineTapped(_ sender: Any) {
        ref.child("Follow Requests").child(Utils.getUserUID()).child(userData!.uid).removeValue()
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
