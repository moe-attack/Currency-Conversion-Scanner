//
//  CreditTableViewCell.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 19/6/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import UIKit

class CreditTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var body: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 10
        addShadowsToView(view: containerView)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
