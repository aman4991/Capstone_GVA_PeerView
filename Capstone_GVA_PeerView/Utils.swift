//
//  Utils.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import Foundation
import Firebase

class Utils
{
    private static var userData: UserData?
    private static var user: User!

    static func setUserData(userData: UserData)
    {
        self.userData = userData
    }

    static func getUserData() -> UserData?
    {
        return self.userData
    }
    
    static func setUser(user: User)
    {
        self.user = user
    }

    static func getUser() -> User
    {
        return self.user
    }

    static func getUserUID() -> String
    {
        return self.user.uid
    }
}
