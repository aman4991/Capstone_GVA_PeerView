//
//  Rating.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import Foundation
import Firebase

class Rating
{
    var userData: UserData?
    var rating: String?

    init(datasnapshot: [String: AnyObject], uid: String) {
        self.userData = UserData(datasnapshot: datasnapshot, uid: uid)
        self.rating = datasnapshot["rating"] as? String
    }

}
