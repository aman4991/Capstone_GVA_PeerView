//
//  Comment.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import Foundation
import Firebase

class Comment
{
    var comment: String!
    var image: String?
    var key: String!
    var name: String!
    var uid: String!

    init(datasnapshot: [String: AnyObject]) {
        self.name = datasnapshot["name"] as? String
        self.image = datasnapshot["image"] as? String
        self.uid = datasnapshot["uid"] as? String
        self.comment = datasnapshot["comment"] as? String
        self.key = datasnapshot["key"] as? String
    }
}
