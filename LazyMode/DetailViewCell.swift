//
//  DetailViewCell.swift
//  LazyMode
//
//  Created by Work on 4/19/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//

import UIKit

class DetailViewCell: UITableViewCell {

    var action: Action? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detail: UILabel!

    @IBAction func didChangeSlider(_ sender: UISlider) {
        detail.text = "\(Int(slider.value))%";
    }
    
    func updateUI(){
        name.text = action?.name
        slider.value = action!.completionRate
        detail.text = "\(Int(slider.value))%";
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
}
