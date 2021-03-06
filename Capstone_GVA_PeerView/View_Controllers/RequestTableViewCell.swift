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
    var userData: UserData!
    {
        didSet
        {
            nameLabel.text = userData!.name
            if let image = userData?.image
            {
                downloadImage(from: URL(string: image), imageView: profileImageView)
            }
        }
    }
    
    var index: IndexPath!
    var delegate: FollowRequestOperations?
    var ref: DatabaseReference!

    override func awakeFromNib() {
        super.awakeFromNib()
        ref = Database.database().reference()
        setImageView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBAction func acceptButton(_ sender: Any) {
        ref.child("Followers").child(Utils.getUserUID()).child(userData!.uid).setValue(userData?.getUserDataMap())
        ref.child("Followers").child(userData!.uid).child(Utils.getUserUID()).setValue(Utils.getUserData()!.getUserDataMap())
        ref.child("Follow Requests").child(Utils.getUserUID()).child(userData!.uid).removeValue()
        delegate?.removeRequest(at: index)
    }
    @IBAction func declineTapped(_ sender: Any) {
        ref.child("Follow Requests").child(Utils.getUserUID()).child(userData!.uid).removeValue()
        delegate?.removeRequest(at: index)
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
    
    func setImageView()
    {
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }
}
