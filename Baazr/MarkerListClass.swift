//
//  MarkerListClass.swift
//  Baazr
//
//  Created by akkhushu on 6/22/19.
//  Copyright © 2019 Baazr. All rights reserved.
//

import Foundation
import UIKit

class MarkerListClass {
    var imageLink = [String]()
    var title: String
    var cost = [String]()
    var id: String
    var description = [String]()
    var distance: Double
    
    init(imageLink: [String], title: String, cost: [String], id: String, distance: Double, description: [String]) {
        self.imageLink = imageLink
        self.title = title
        self.cost = cost
        self.id = id
        self.distance = distance
        self.description = description
    }
}
