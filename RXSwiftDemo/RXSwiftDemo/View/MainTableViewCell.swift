//
//  MainTableViewCell.swift
//  RXSwiftDemo
//
//  Created by admin on 14/08/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textLabel?.numberOfLines = 0;
        
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
