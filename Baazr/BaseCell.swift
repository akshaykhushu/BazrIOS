//
//  BaseCell.swift
//  Baazr
//
//  Created by akkhushu on 7/2/19.
//  Copyright © 2019 Baazr. All rights reserved.
//

import Foundation
class BaseCell: UICollectionViewCell
{
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews()
    {
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init (coder:) has been implemented")
    }
}
