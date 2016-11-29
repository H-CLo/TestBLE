//
//  BLEObject.swift
//  TestBLE
//
//  Created by Hung Chang Lo on 11/16/16.
//  Copyright © 2016 Go-Trust. All rights reserved.
//

import Foundation
import CoreBluetooth

public class BLEScanList {
    var blePeripheral : CBPeripheral?
    var bleIdentifier : String?
    var bleName       : String?
    var bleState      : CBPeripheralState?
    var bleRSSI       : NSNumber?
    
    init(peripheral: CBPeripheral? , identifier: String? , name: String?, state: CBPeripheralState?, rssi: NSNumber?) {
        blePeripheral = peripheral
        bleIdentifier = identifier
        bleName       = name
        bleState      = state
        bleRSSI       = rssi
    }
}

public class BLEServiceInfo {
    var service: CBService!
    var characteristics: [CBCharacteristic]
    
    init(service: CBService, characteristics: [CBCharacteristic]) {
        self.service = service
        self.characteristics = characteristics
    }
}
