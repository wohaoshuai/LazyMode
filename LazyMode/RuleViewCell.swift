//
//  RuleViewCell.swift
//  LazyMode
//  This class is not used right now!
//
//  Created by Tony on 4/29/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//

import UIKit

class RuleViewCell: UITableViewCell {
    var action: Action!
    
    @IBOutlet weak var actionTitle: UILabel!
    
    @IBOutlet weak var typePicker: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
