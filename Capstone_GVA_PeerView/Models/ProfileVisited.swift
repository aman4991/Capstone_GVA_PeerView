//
//  ProfileVisited.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import Foundation
import Firebase

class ProfileVisited
{
    var userData: UserData?
    var date: String?

    init(datasnapshot: [String: AnyObject], uid: String) {
        self.userData = UserData(datasnapshot: datasnapshot, uid: uid)
        self.date = datasnapshot["date"] as? String
    }

}
