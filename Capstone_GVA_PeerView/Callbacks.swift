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
