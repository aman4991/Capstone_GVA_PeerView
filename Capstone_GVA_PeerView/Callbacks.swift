//
//  Callbacks.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import Foundation
import MapKit

protocol Callbacks {
    func setCoordinates(coordinates: CLLocationCoordinate2D, title: String)
}

protocol ToMove {
    func moveToMap(coordinates: CLLocationCoordinate2D)
}

protocol FollowRequestOperations {
    func removeRequest(at: IndexPath)
}
