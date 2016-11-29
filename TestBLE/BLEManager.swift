//
//  BLEManager.swift
//  TestBLE
//
//  Created by Hung Chang Lo on 11/15/16.
//  Copyright © 2016 Go-Trust. All rights reserved.
//

import Foundation
import CoreBluetooth

/* Define callback function for CBCentralManagerDelegate, CBPeripheralDelegate */
typealias DiscoverPeripheralCompletion                = (_ peripheral        : CBPeripheral,
                                                         _ advertisementData : [String : AnyObject],
                                                         _ RSSI              : NSNumber) -> Void
typealias ConnectPeripheralCompletion                 = (_ peripheral        : CBPeripheral,
                                                         _ error             : NSError?) -> Void
typealias DiscoverServiceCompletion                   = (_ peripheral        : CBPeripheral,
                                                         _ error             : Error?) -> Void
typealias DiscoverCharacteristicsForServiceCompletion = (_ peripheral        : CBPeripheral,
                                                         _ service           : CBService,
                                                         _ error             : Error?) -> Void
typealias DisconnectPeripheralCompletion              = (_ peripheral        : CBPeripheral,
                                                         _ error             : Error?) -> Void
typealias ReceiveDataCompletion                       = (_ data              : Data?,
                                                         _ peripheral        : CBPeripheral,
                                                         _ characteristic    : CBCharacteristic) -> Void
typealias ReadResponseCompletion                      = (_ success           : Bool) -> Void
typealias WriteResponseCompletion                     = (_ success           : Bool) -> Void
typealias SetNotificationResponseCompletion           = (_ success           : Bool) -> Void

class BLEManager: NSObject {
    var didDiscoverPeripheralCompletioin               : DiscoverPeripheralCompletion?
    var didConnectPeripheralCompletion                 : ConnectPeripheralCompletion?
    var didDiscoverServiceCompletion                   : DiscoverServiceCompletion?
    var didDiscoverCharacteristicsForServiceCompletion : DiscoverCharacteristicsForServiceCompletion?
    var didDisconnectPeripheralCompletion              : DisconnectPeripheralCompletion?
    var didReceiveDataCompletion                       : ReceiveDataCompletion?
    var didReadResponseCompletion                      : ReadResponseCompletion?
    var didWriteResponseCompletion                     : WriteResponseCompletion?
    var didSetNotificationCompletion                   : SetNotificationResponseCompletion?
    
    //MARK: - Basic Settings
    private var centralManager: CBCentralManager?
    
    // Init the CentralManager
    required init(queue: DispatchQueue) {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: queue)
    }
    
    deinit {
        centralManager = nil
        releaseBlocks()
    }
    
    private func releaseBlocks() {
        didDiscoverPeripheralCompletioin               = nil
        didConnectPeripheralCompletion                 = nil
        didDiscoverServiceCompletion                   = nil
        didDiscoverCharacteristicsForServiceCompletion = nil
        didDisconnectPeripheralCompletion              = nil
        didReceiveDataCompletion                       = nil
        didReadResponseCompletion                      = nil
        didWriteResponseCompletion                     = nil
        didSetNotificationCompletion                   = nil
    }
    
    private func closeAllNotification(peripheral: CBPeripheral) {
        if let services  = peripheral.services {
            for service in services {
                if let characteristics = service.characteristics {
                    for characteristic in characteristics {
                        if characteristic.isNotifying {
                            peripheral.setNotifyValue(false, for: characteristic)
                        }
                    }
                }
            }
        }
    }
    
    /**
     *  MARK: - BLE Discoverying
     */
    func scanWithServiceUUID(serviceUUID: String?, discoverPeripheralCompletion: @escaping DiscoverPeripheralCompletion) {
        self.didDiscoverPeripheralCompletioin = discoverPeripheralCompletion
        
        if let uuidStr = serviceUUID {
            let uuid = [CBUUID.init(string: uuidStr)]
            centralManager?.scanForPeripherals(withServices: uuid, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
        else {
            centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    func stopScan() {
        centralManager?.stopScan()
    }
    
    /**
     *  MARK: - BLE Connecting
     */
    func connnect(peripheral: CBPeripheral, completion: @escaping ConnectPeripheralCompletion) {
        self.didConnectPeripheralCompletion = completion
        centralManager?.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey : NSNumber(value: true)])
    }
    
    /**
     *  MARK: - BLE Disconnect
     */
    func disconnect(_ peripheral: CBPeripheral, completion: @escaping DisconnectPeripheralCompletion) {
        BLEUtils.prettyLog()
        closeAllNotification(peripheral: peripheral)
        self.didDisconnectPeripheralCompletion = completion
        
        // start from disconnnect
        centralManager?.cancelPeripheralConnection(peripheral)
    }
    
    /**
     *  MARK: - BLE Discovery Service
     */
    func discoverService(peripheral: CBPeripheral, serviceUUID: [CBUUID]?, completion: @escaping DiscoverServiceCompletion) {
        BLEUtils.prettyLog()
        self.didDiscoverServiceCompletion = completion
        
        // start from getting service
        peripheral.discoverServices(serviceUUID)
    }
    
    /**
     *  MARK: - BLE Discovery Charateristic
     */
    func discoverCharacteristicForService(peripheral: CBPeripheral, characteristicUUID: [CBUUID]?, service: CBService, completion: @escaping DiscoverCharacteristicsForServiceCompletion) {
        BLEUtils.prettyLog()
        self.didDiscoverCharacteristicsForServiceCompletion = completion
        
        // start from getting characteristic
        peripheral.discoverCharacteristics(characteristicUUID, for: service)
    }
    
    /**
     *  MARK: - BLE Interacting
     */
    
    //Reading
    func readValue(peripheral: CBPeripheral, characteristic: CBCharacteristic, completion: @escaping ReceiveDataCompletion) {
        self.didReceiveDataCompletion = completion
        
        // start from readValue
        peripheral.readValue(for: characteristic)
    }
    
    //Write Value
    func writeValue(peripheral: CBPeripheral, characteristic: CBCharacteristic, data: Data, withResponse: Bool, completion: @escaping WriteResponseCompletion) {
        self.didWriteResponseCompletion = completion
        peripheral.writeValue(data, for: characteristic, type: withResponse ? .withResponse : .withoutResponse)
    }
    
    //Set Notify
    func setNotificationState(peripheral: CBPeripheral, characteristic: CBCharacteristic, onOroff: Bool, completion: @escaping SetNotificationResponseCompletion) {
        let p = characteristic.isNotifying
        let q = onOroff
        if (p || q) && !(p && q) {
            self.didSetNotificationCompletion = completion
            peripheral.setNotifyValue(onOroff, for: characteristic)
        }
    }
}

extension BLEManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            NSLog("Bluetooth Power On")
        case .poweredOff:
            NSLog("Bluetooth Power off")
        case .resetting:
            NSLog("Bluetooth Resetting")
        case .unknown:
            NSLog("Bluetooth Unknown")
        case .unauthorized:
            NSLog("Bluetooth Unauthorized")
        case .unsupported:
            NSLog("Bluetooth Unsupported")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        didDiscoverPeripheralCompletioin?(peripheral, advertisementData as [String : AnyObject], RSSI)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        BLEUtils.prettyLog()
        peripheral.delegate = self
        didConnectPeripheralCompletion?(peripheral, nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        BLEUtils.prettyLog()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        BLEUtils.prettyLog()
        didDisconnectPeripheralCompletion?(peripheral, error)
    }
}

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        BLEUtils.prettyLog()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        BLEUtils.prettyLog()
        didDiscoverServiceCompletion?(peripheral, error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        BLEUtils.prettyLog()
        didDiscoverCharacteristicsForServiceCompletion?(peripheral, service, error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            BLEUtils.prettyLog(message: "ERROR:" + error.debugDescription)
            self.didReadResponseCompletion?(false)
            return
        }
        BLEUtils.prettyLog()
        
        self.didReadResponseCompletion?(true)
        self.didReadResponseCompletion = nil
        self.didReceiveDataCompletion?(characteristic.value, peripheral, characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            BLEUtils.prettyLog(message: "ERROR:" + error.debugDescription)
            self.didWriteResponseCompletion?(false)
            return
        }
        BLEUtils.prettyLog()
        self.didWriteResponseCompletion?(true)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            BLEUtils.prettyLog(message: "ERROR:" + error.debugDescription)
            self.didSetNotificationCompletion?(false)
            return
        }
        BLEUtils.prettyLog()
        self.didSetNotificationCompletion?(true)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        
    }
    
}


