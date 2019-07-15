//
//  CustomCells.swift
//  Baazr
//
//  Created by akkhushu on 6/21/19.
//  Copyright © 2019 Baazr. All rights reserved.
//

import Foundation
import UIKit
import Imaginary
import Cache

class CustomCells : UITableViewCell {
    
    @IBOutlet weak var ListViewImageView: UIImageView!
    @IBOutlet weak var ListViewCostView: UILabel!
    @IBOutlet weak var ListViewTitleView: UILabel!
    
    func setCells(markerListClassInstance : MarkerListClass){
        
        var imageUrl = URL(string : markerListClassInstance.imageLink[0])
        ListViewImageView.setImage(url: imageUrl!)
        ListViewCostView.text =  "\(String(markerListClassInstance.distance)) \("Mi | ") \(markerListClassInstance.cost[0])"
        ListViewTitleView.text = markerListClassInstance.title
    }
    
}
