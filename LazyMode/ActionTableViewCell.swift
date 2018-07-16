//
//  ActionTableViewCell.swift
//  LazyMode
//
//  Created by Work on 4/7/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//

import UIKit

// This calss is a customed cell in ActionTableView
class ActionTableViewCell: UITableViewCell {
    
    @IBInspectable var expanableNum: Int = 0
    @IBInspectable var originalHeight: CGFloat = 44
    var toBeExpand: Bool = false
    var toBeClose: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
