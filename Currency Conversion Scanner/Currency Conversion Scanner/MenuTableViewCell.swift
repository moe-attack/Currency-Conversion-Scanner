//
//  MenuTableViewCell.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 19/6/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    // Link the cell UI components to be configured in View Controller
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerText: UILabel!
    
    /*
     This function is called when the view loads a cell. Additional UI set up is defined here.
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        // Round corner and shadows to make app more presenting, also as one of the signature of the app.
        containerView.layer.cornerRadius = 10
        addShadowsToView(view: containerView)
    }

}
