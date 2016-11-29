//
//  BLECharacteristicTableViewCell.swift
//  TestBLE
//
//  Created by Hung Chang Lo on 11/16/16.
//  Copyright © 2016 Go-Trust. All rights reserved.
//

import UIKit

class BLECharacteristicTableViewCell: UITableViewCell {

    @IBOutlet weak var lblUUID: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var lblProp: UILabel!
    @IBOutlet weak var lblPropHex: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
