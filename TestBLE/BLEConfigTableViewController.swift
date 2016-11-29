//
//  BLEConfigTableViewController.swift
//  TestBLE
//
//  Created by Hung Chang Lo on 11/15/16.
//  Copyright © 2016 Go-Trust. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEConfigTableViewController: UITableViewController {
    
    // Pass by segue
    var peripheral: BLEScanList!
    var centralManager: BLEManager!
    
    // define service and characteristic
    var bleService: [BLEServiceInfo] = [BLEServiceInfo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "BLECharacteristicTableViewCell", bundle: nil), forCellReuseIdentifier: "BLECharacteristicTableViewCell")
        
        // start connncet Peripheral
        connect(peripheral: peripheral.blePeripheral!)
    }
    
    /**
        Implement CBCentralManagerDelegate didConnect with a callback function
     
        Callback function return: Implement discoverService function
     
        - parameter peripheral: CBPeripheral
     */
    func connect(peripheral: CBPeripheral) {
        centralManager.connnect(peripheral: peripheral) {
            peripheral, error -> Void in
            if error != nil {
                BLEUtils.prettyLog(message: "ERROR: CONNECT PERIPHERAL FAIL, ERROR = \(error)")
                return
            }
            
            if peripheral.state == .connected {
                BLEUtils.prettyLog(message: "INFO: BLE connnect success")
                self.discoverService(peripheral: peripheral)
            }
        }
    }
    
    /**
        Implement CBPeripheralDelegate didDiscoverServices with a callback function
     
        Callback function return: 
          1. Make new BLEServiceInfo instance and put into the Array of BLEServiceInfo
          2. Implement discoverCharacteristic function
     
        - parameter peripheral: CBPeripheral
     */
    func discoverService(peripheral: CBPeripheral) {
        BLEUtils.prettyLog(message: "INFO: BLE start discovering service")
        
        centralManager.discoverService(peripheral: peripheral, serviceUUID: nil) {
            peripheral, error -> Void in
            if error != nil {
                BLEUtils.prettyLog(message: "ERROR: PERIPHERAL DISCOVER SERVICE FAIL, ERROR = \(error)")
                return
            }
            
            for serviceObj in peripheral.services! {
                let service: CBService = serviceObj
                let isServiceIncluded = self.bleService.filter { (item: BLEServiceInfo) -> Bool in
                    return item.service.uuid == service.uuid
                    }.count
                if isServiceIncluded == 0 {
                    self.bleService.append(BLEServiceInfo(service: service, characteristics: []))
                }

                self.discoverCharacteristic(peripheral: peripheral, characteristicUUIDs: nil, service: service)
            }
            
        }
    }
    
    /**
        Implement CBPeripheralDelegate didDiscoverCharacteristicsFor Service with a callback function
     
        Callback function return:
          1. Put characteristic for each service which has same UUID
          2. Reload tableview -> it must execute in the main thread asynchronize
     
        - parameter peripheral: CBPeripheral
        - parameter characteristicUUIDs: [CBUUID]?
        - parameter service: CBService
     */
    func discoverCharacteristic(peripheral: CBPeripheral, characteristicUUIDs: [CBUUID]?, service: CBService) {
        BLEUtils.prettyLog(message: "INFO: BLE start discovering characteristic")
        
        centralManager.discoverCharacteristicForService(peripheral: peripheral, characteristicUUID: characteristicUUIDs, service: service) {
            peripheral, service, error -> Void in
            if error != nil {
                BLEUtils.prettyLog(message: "ERROR: PERIPHERAL DISCOVER CHARACTERISTIC FAIL, ERROR = \(error)")
                return
            }
            
            let serviceCharacteristic = service.characteristics
            for item in self.bleService {
                if item.service.uuid == service.uuid {
                    item.characteristics = serviceCharacteristic!
                    break
                }
            }
            
            // Reload UI, must execute in the background
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //NSLog("UUID = \(bleService[section].service.uuid.uuidString), service description = \(bleService[section].service.uuid.description)")
        return bleService[section].service.uuid.description
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return bleService.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return bleService[section].characteristics.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BLECharacteristicTableViewCell = tableView.dequeueReusableCell(withIdentifier: "BLECharacteristicTableViewCell") as! BLECharacteristicTableViewCell
        cell.accessoryType = .disclosureIndicator
        
        cell.lblUUID.text = bleService[indexPath.section].characteristics[indexPath.row].uuid.uuidString
        cell.lblName.text = bleService[indexPath.section].characteristics[indexPath.row].uuid.description
        cell.lblValue.text = bleService[indexPath.section].characteristics[indexPath.row].value?.description ?? "null"
        cell.lblProp.text = bleService[indexPath.section].characteristics[indexPath.row].getPropContent()
        cell.lblPropHex.text = String(format: "0x%02X", bleService[indexPath.section].characteristics[indexPath.row].properties.rawValue)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 185
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showBLETransportViewController", sender: bleService[indexPath.section].characteristics[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "showBLETransportViewController" {
            if let targetVC = segue.destination as? BLETransportViewController {
                targetVC.centralManager = self.centralManager
                targetVC.peripheral = self.peripheral.blePeripheral!
                targetVC.char = sender as! CBCharacteristic
            }
        }
    }

}
