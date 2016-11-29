//
//  BLEUtils.swift
//  TestBLE
//
//  Created by Hung Chang Lo on 11/15/16.
//  Copyright © 2016 Go-Trust. All rights reserved.
//

import Foundation
import CoreBluetooth

public class BLEUtils {
    
    public static func convertBLEStateToStr(state: CBPeripheralState) -> String {
        switch state {
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting"
        case .disconnected:
            return "Disconnected"
        case .disconnecting:
            return "Disconnecting"
        }
    }
    
    public static func prettyLog(message: String = "", file:String = #file, function:String = #function, line:Int = #line) {
        
        print("\((file as NSString).lastPathComponent)(\(line)) \(function) \(message)")
    }
}

extension CBCharacteristic {
    func getPropContent() -> String {
        var propContent = ""
        if self.properties.intersection(.broadcast) != [] {
            propContent += "Broadcast,"
        }
        if self.properties.intersection(.read) != [] {
            propContent += "Read,"
        }
        if self.properties.intersection(.writeWithoutResponse) != [] {
            propContent += "WriteWithoutResponse,"
        }
        if self.properties.intersection(.write) != [] {
            propContent += "Write,"
        }
        if self.properties.intersection(.notify) != [] {
            propContent += "Notify,"
        }
        if self.properties.intersection(.indicate) != [] {
            propContent += "Indicate,"
        }
        if self.properties.intersection(.authenticatedSignedWrites) != [] {
            propContent += "AuthenticatedSignedWrites,"
        }
        if self.properties.intersection(.extendedProperties) != [] {
            propContent += "ExtendedProperties,"
        }
        if self.properties.intersection(.notifyEncryptionRequired) != [] {
            propContent += "NotifyEncryptionRequired,"
        }
        if self.properties.intersection(.indicateEncryptionRequired) != [] {
            propContent += "IndicateEncryptionRequired,"
        }
        if !propContent.isEmpty {
            let lastContent = propContent.index(propContent.endIndex, offsetBy: -1)
            propContent = propContent.substring(to: lastContent)
        }
        
        return propContent
    }
    
    func isReadable() -> Bool {
        if self.properties.intersection(.read) != [] {
            return true
        }
        else {
            return false
        }
    }
    
    func isWriteable() -> Bool {
        if self.properties.intersection(.write) != [] {
            return true
        }
        else {
            return false
        }
    }
    
    func isNotifyable() -> Bool {
        if self.properties.intersection(.notify) != [] {
            return true
        }
        else {
            return false
        }
    }
}
