//
//  BLETableViewController.swift
//  TestBLE
//
//  Created by Hung Chang Lo on 11/14/16.
//  Copyright © 2016 Go-Trust. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLETableViewController: UITableViewController {
    
    @IBOutlet weak var btnScan: UIBarButtonItem!
    @IBOutlet weak var btnRepeatScan: UIBarButtonItem!
    @IBOutlet var tbvBLE: UITableView!
    
    let SECTION_TITLE = "Peripheral nearby"
    var selectedPeripheral: CBPeripheral?
    var centralManager: BLEManager?
    var bleScanLists: [BLEScanList] = [BLEScanList]()
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add BLETableViewCell to Controller
        tableView.register(UINib(nibName: "BLETableViewCell", bundle: nil), forCellReuseIdentifier: "BLETableViewCell")
        
        // Init centralManager
        let queue = DispatchQueue(label: "DispatchQueueForBLE")
        centralManager = BLEManager(queue: queue)
        
        // Add refreshControl to tableView
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(BLETableViewController.refresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /* Check if there is a peripheral connected. Connected -> disConnectr */
        if selectedPeripheral?.state == .connected {
            BLEUtils.prettyLog()
            centralManager?.disconnect(selectedPeripheral!) {
                peripheral, error -> Void in
                if error != nil {
                    BLEUtils.prettyLog(message: "ERROR: disconnect peripheral fail, error = \(error)")
                    return
                }
                BLEUtils.prettyLog(message: "INFO: peripheral \(peripheral) disConnnect Success")
            }
        }
    }

    @IBAction func btnRepeatScan(_ sender: UIBarButtonItem) {
        if btnRepeatScan.title == "Repeat Scan" {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(BLETableViewController.startScan), userInfo: nil, repeats: true)
            btnRepeatScan.title = "Stop Scanning"
        }
        else {
            stopScan()
            timer?.invalidate()
            btnRepeatScan.title = "Repeat Scan"
        }
    }
    @IBAction func btnScan(_ sender: UIBarButtonItem) {
        // Start to sacn
        startScan()
        
        // Set timer to stop scanning in 3 seconds
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(BLETableViewController.stopScan), userInfo: nil, repeats: false)
    }
    
    func refresh() {
        // Start to sacn
        startScan()
        
        // Set timer to stop scanning in 3 seconds
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(BLETableViewController.stopScan), userInfo: nil, repeats: false)
    }
    
    /**
        Implement CBCentralManagerDelegate didDiscover with a callback function
     
        Callback function return: 
          1. Filter the existing BLE device
          2. Instance a new BLEScanList and append if the UUIDString is a new one
          3. Update the existing BLE device information
     */
    func startScan() {
        btnScan.isEnabled = false
        bleScanLists.removeAll()
        centralManager?.scanWithServiceUUID(serviceUUID: nil) {
            peripheral, advertisement, RSSI -> Void in
            
            let temp = self.bleScanLists.filter { (BLE) -> Bool in
                return BLE.bleIdentifier == peripheral.identifier.uuidString
            }
            
            // if there is new bleList, add to bleScanLists
            if temp.count == 0 {
                let bleScanList = BLEScanList(peripheral: peripheral, identifier: peripheral.identifier.uuidString, name: peripheral.name, state: peripheral.state, rssi: RSSI)
                self.bleScanLists.append(bleScanList)
            }
            
            // update information
            if self.bleScanLists.count != 0 {
                for var index in self.bleScanLists {
                    if index.bleIdentifier == peripheral.identifier.uuidString {
                        index.bleName  = peripheral.name
                        index.bleRSSI  = RSSI
                        index.bleState = peripheral.state
                    }
                }
            }
            // reload tableView in the main thread async
            DispatchQueue.main.async {
                self.tbvBLE.reloadData()
            }
        }
    }
    
    /* Implement CBCentralManager StopScan */
    func stopScan() {
        centralManager?.stopScan()
        btnScan.isEnabled = true
        
        // stop refreshing
        refreshControl?.endRefreshing()
        
        tbvBLE.reloadData()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SECTION_TITLE
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return bleScanLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BLETableViewCell = tableView.dequeueReusableCell(withIdentifier: "BLETableViewCell", for: indexPath) as! BLETableViewCell
        cell.accessoryType = .disclosureIndicator
        
        cell.lblIdentifier.text = bleScanLists[indexPath.row].bleIdentifier
        cell.lblName.text       = bleScanLists[indexPath.row].bleName
        cell.lblState.text      = BLEUtils.convertBLEStateToStr(state: (bleScanLists[indexPath.row].bleState)!)
        cell.lblRSSI.text       = String(describing: bleScanLists[indexPath.row].bleRSSI!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        NSLog("inde path row = \(indexPath.row)")
        selectedPeripheral = bleScanLists[indexPath.row].blePeripheral!
        NSLog("selectedPeripheral = \(selectedPeripheral!)")
        self.performSegue(withIdentifier: "showBLEConfigTableView", sender: bleScanLists[indexPath.row])
    }
    
    /* Prepare value for segue */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBLEConfigTableView" {
            if let targetTC = segue.destination as? BLEConfigTableViewController {
                targetTC.peripheral = sender as! BLEScanList
                targetTC.centralManager = self.centralManager
            }
        }
    }
}
