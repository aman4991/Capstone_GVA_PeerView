//
//  Utils.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import Foundation

class Utils
{
    private static var userData: UserData?

    static func setUserData(userData: UserData)
    {
        self.userData = userData
    }

    static func getUserData() -> UserData?
    {
        return self.userData
    }
}
