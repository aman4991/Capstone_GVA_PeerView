//
//  UserData.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import Foundation
import Firebase

class UserData
{
    var name: String!
    var uid: String!
    var image: String!
    var status: String?

    init(datasnapshot: [String: AnyObject], uid: String) {
        self.name = datasnapshot["name"] as? String
        self.image = datasnapshot["image"] as? String
        self.uid = uid
        self.status = datasnapshot["status"] as? String
    }
}
