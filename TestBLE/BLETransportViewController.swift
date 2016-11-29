//
//  BLETransportViewController.swift
//  TestBLE
//
//  Created by Hung Chang Lo on 11/18/16.
//  Copyright © 2016 Go-Trust. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLETransportViewController: UIViewController {
    
    var centralManager: BLEManager!
    var peripheral    : CBPeripheral!
    var char          : CBCharacteristic!

    @IBOutlet weak var lblUUID: UILabel!
    @IBOutlet weak var lblPropHex: UILabel!
    @IBOutlet weak var lblProp: UILabel!
    @IBOutlet weak var tvResponse: UITextView!
    
    @IBOutlet weak var btnRead: UIButton!
    @IBOutlet weak var btnWrite: UIButton!
    @IBOutlet weak var btnNotify: UIButton!
    
    @IBAction func btnRead(_ sender: UIButton) {
        centralManager.readValue(peripheral: peripheral, characteristic: char) {
            (data, peripheral, characteristic) -> Void in
            BLEUtils.prettyLog(message: "INFO: Success to read value")
            DispatchQueue.main.async {
                let respStr = String(data: data!, encoding: String.Encoding.utf8)
                self.tvResponse.text = respStr
            }
        }
    }
    
    @IBAction func btnWrite(_ sender: UIButton) {
        let data = "123".data(using: String.Encoding.utf8)
        centralManager.writeValue(peripheral: peripheral, characteristic: char, data: data!, withResponse: true) {
            success -> Void in
            if !success {
                BLEUtils.prettyLog(message: "ERROR: FAIL TO WRITE VALUE")
                return
            }
            BLEUtils.prettyLog(message: "INFO: Success to write value, char value = \(String(data: self.char.value!, encoding: String.Encoding.utf8)))")
        }
    }
    
    @IBAction func btnNotify(_ sender: UIButton) {
        centralManager.setNotificationState(peripheral: peripheral, characteristic: char, onOroff: true) {
            success -> Void in
            if !success {
                BLEUtils.prettyLog(message: "ERROR: FAIL TO SET NOTIFICATION STATE")
                return
            }
            BLEUtils.prettyLog(message: "INFO: Success to set notification state, char value = \(String(data: self.char.value!, encoding: String.Encoding.utf8))")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !char.isReadable() {
            btnRead.isEnabled = false
        }
        
        if !char.isWriteable() {
            btnWrite.isEnabled = false
        }
        
        if !char.isNotifyable() {
            btnNotify.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblUUID.text = char.uuid.uuidString
        lblProp.text = char.getPropContent()
        lblPropHex.text = String(format: "0x%02X", char.properties.rawValue)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
