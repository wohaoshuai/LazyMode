//
//  StatusBlockView.swift
//  LazyMode
//
//  This class representing the StatusBlockView created in StatusBlockView.xib file
//
//  Created by Work on 4/14/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//

import UIKit

class StatusBlockView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }

     }
     
    */
    
    // major outlets for important componet in the StatusBlockView.xib
    @IBOutlet weak var typeDisplay: UILabel!
    @IBOutlet weak var numberDisplay: UILabel!
    @IBOutlet weak var unitDisplay: UILabel!
    @IBOutlet weak var statusBar: UIImageView!

    // Computed property for each important component
    @IBInspectable var statusImage:UIImage?{
        get {
            return statusBar.image
        }
        set {
            statusBar.image = newValue
        }
    }
    
    @IBInspectable var number:Int{
        get {
            return Int(numberDisplay.text!)!
        }
        set {
            if (newValue > 99){
                numberDisplay.text = "∞"
            } else {
               numberDisplay.text = String(newValue)
            }
        }
    }
    
    @IBInspectable var unit:String?{
        get {
            return unitDisplay.text
        }
        set {
            unitDisplay.text = newValue
        }
    }
    
    @IBInspectable var type:String?{
        get {
            return typeDisplay.text
        }
        set {
            typeDisplay.text = newValue
        }
    }
    
    var view: UIView!
    var nibName: String = "StatusBlockView"
    
    // init from nib
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp(){
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView{
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
}
