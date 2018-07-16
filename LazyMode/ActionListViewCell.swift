//
//  ActionListViewCell.swift
//  LazyMode
//
//  Created by Work on 4/19/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//

import UIKit

class ActionListViewCell: UITableViewCell {
    
    @IBOutlet weak var completeButton: UIButton!
    var action : Action?{
        didSet{
            title.text = action!.name
            updateUI()
        }
    }
    @IBOutlet weak var title: UILabel!
    
    @IBAction func complete(_ sender: UIButton) {
        if action!.completionRate == 100{
            action!.completionRate = 0;
        } else {
            action!.completionRate = 100;
        }
        updateUI()
    }
    
    // update UI
    // precisely, changing the color according to the completionRate of action
    func updateUI(){
        if action!.completionRate == 100{
            completeButton.setBackgroundImage(UIImage(named: "Complete"), for: UIControlState())
            title.textColor = UIColor.lightGray
        } else {
            completeButton.setBackgroundImage(UIImage(named: "Incomplete"), for: UIControlState())
            title.textColor = UIColor.black
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
