//
//  WorkingHoursTableViewCell.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 11.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit

class WorkingHoursTableViewCell: UITableViewCell {

    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
