//
//  PostCollectionViewCell.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var textView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func showLocationTapped(_ sender: Any) {
    }


}
