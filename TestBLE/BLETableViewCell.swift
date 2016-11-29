//
//  BLETableViewCell.swift
//  TestBLE
//
//  Created by Hung Chang Lo on 11/14/16.
//  Copyright © 2016 Go-Trust. All rights reserved.
//

import UIKit

class BLETableViewCell: UITableViewCell {

    @IBOutlet weak var lblIdentifier: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblState: UILabel!
    @IBOutlet weak var lblRSSI: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
