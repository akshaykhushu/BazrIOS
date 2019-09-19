//
//  POIItem.swift
//  Baazr
//
//  Created by akkhushu on 6/21/19.
//  Copyright © 2019 Baazr. All rights reserved.
//

import Foundation
import GooglePlaces
import GoogleMaps

class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var title: String!
    var state: String!
    
    init(position: CLLocationCoordinate2D, title: String, state: String) {
        self.position = position
        self.title = title
        self.state = state
    }
}
