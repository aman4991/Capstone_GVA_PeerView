//
//  Post.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import Foundation
import Firebase

class Post
{
    var text: String?
    var ltitle: String?
    var lat: String?
    var lng: String?
    var image: String?
    var rating: String?
    var user: String?
    var key: String?

    init(datasnapshot: [String: AnyObject]) {
        self.text = datasnapshot["text"] as? String
        self.ltitle = datasnapshot["ltitle"] as? String
        self.lat = datasnapshot["lat"] as? String
        self.lng = datasnapshot["lng"] as? String
        self.image = datasnapshot["image"] as? String
        self.rating = datasnapshot["rating"] as? String
        self.user = datasnapshot["user"] as? String
        self.key = datasnapshot["key"] as? String
    }
}
