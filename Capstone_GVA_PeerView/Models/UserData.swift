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
    
    func getUserDataMap() -> [String: String]
    {
        var map: [String: String] = [:]
        map["name"] = name
        map["uid"] = uid
        map["image"] = image
        map["status"] = status
        return map
    }
}
