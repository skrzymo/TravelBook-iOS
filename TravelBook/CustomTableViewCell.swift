//
//  CustomTableViewCell.swift
//  TravelBook
//
//  Created by skrzymo on 28/01/2019.
//  Copyright © 2019 skrzymo. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    static let reusableIdentifier = "Cell"
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var country: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
