//
//  BLEScanner.swift
//  BLETest
//
//  Created by Titus Cheng on 12/5/14.
//  Copyright (c) 2014 Braison. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc protocol BLEScannerDelegate
{
    func bleScannerUpdate(updates: String)
    optional func bleScannerDiscovered(peripherals: CBPeripheral)
    optional func bleScannerDidUpdateAdvertisementStatus(isOn: Bool)
    func bleScannerConnectedTo(deviceName: String)
    func bleScannerUpdateConnectionStatus(deviceName: String, status: String)
}

protocol BLEScannerDeviceDiscoveryDelegate
{
    func bleScannerDiscovered(peripherals: CBPeripheral)
}

protocol BLEScannerServiceDiscoveryDelegate
{
    func bleScannerDiscoveredService(service: CBService)
}

protocol BLEScannerCharacteristicDiscoveryDelegate
{
    func bleScannerDiscoveredCharacteristic(theCharacteristic: CBCharacteristic)
}

private let _BLEScannerSharedInstance = BLEScanner()

class BLEScanner:NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate

{
    let bleManager: CBCentralManager!
    var allDevices: [CBPeripheral] = []
    var peripheral: CBPeripheral!
    var deviceDelegate: BLEScannerDeviceDiscoveryDelegate!
    var delegate: BLEScannerDelegate!
    var peripheralManager:CBPeripheralManager!
    var targetCharacteristic: CBCharacteristic!
    var service: BLEScannerServiceDiscoveryDelegate!
    var characteristic: BLEScannerCharacteristicDiscoveryDelegate!
    var selectedService: CBService!
    var selectedCharacteristic: CBCharacteristic!
    
    class func sharedInstance() -> BLEScanner {
        return _BLEScannerSharedInstance
    }
    
    override init() {
        super.init()
        bleManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)

    }
    func startScan() {
        bleManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func stopScan() {
        bleManager.stopScan()
    }
    
    func sendData(data: String) {
        if(peripheral != nil) {
            var characteristicUUID = CBUUID(string: "5810FA38-7699-4226-AFB2-D3B3AA025592")
            var characteristic = CBCharacteristic()
//            var num = 12
//            let myData = NSData(bytes: &num, length:sizeofValue(num))
           peripheral.writeValue(data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), forCharacteristic: selectedCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            delegate.bleScannerUpdate("Sending data '\(data)'...")
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        delegate.bleScannerUpdate("Did receive data: \(characteristic.value)")
    }
    
    func peripheral(peripheral: CBPeripheral!, didWriteValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if(error != nil) {
            delegate.bleScannerUpdate("error in writing data to device: \(error)")
        } else {
            delegate.bleScannerUpdate("Did write value to device")
        }
    }
    
    func discoverServices() {
        if(peripheral != nil) {
            peripheral.discoverServices([CBUUID(string: "C48A1473-D2E6-4678-AFC9-B610603BFD72")])
        }
    }
    
    func chooseThisService(theService: CBService) {
        selectedService = theService
    }
    
    
    func startAdvertise(deviceID: String) {
        var identity: NSString!
        if(deviceID == "BF5FB668-BCEE-4C75-B859-F976FC4EFF09") {
            identity = NSString(string: "Ki Kwang Sung")
        }
        else if(deviceID == "B94B0E41-309B-410F-A727-7B68BD1A9501") {
            identity = NSString(string: "Kim Ju Yoon")
        }
        else if(deviceID == "4330D6E7-5D33-4C0E-9980-0EE8DC3270C2") {
            identity = NSString(string: "Titus Cheng")
        }
        else if(deviceID == "09F1CFB3-FA0F-4D80-9086-CC33499716E8"){
            identity = NSString(string: "Mason Joo")
        } else {
            identity = NSString(string: "unknown device")
        }
        var serviceUUID = CBUUID(string: "C48A1473-D2E6-4678-AFC9-B610603BFD72")
        var service: CBMutableService = CBMutableService(type: serviceUUID, primary: true)
        var characteristicUUID = CBUUID(string: "5810FA38-7699-4226-AFB2-D3B3AA025592")
        var characteristic = CBMutableCharacteristic(type: characteristicUUID, properties:CBCharacteristicProperties.Write, value: nil, permissions: CBAttributePermissions.Writeable)
        service.characteristics = [characteristic]
        peripheralManager.addService(service)
        let uuids = [serviceUUID]
        let advData = [CBAdvertisementDataLocalNameKey: identity, CBAdvertisementDataServiceUUIDsKey:uuids]
        peripheralManager.startAdvertising(advData)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didAddService service: CBService!, error: NSError!) {
        if(error != nil) {
            delegate.bleScannerUpdate("error in adding service: \(error.localizedFailureReason) \(error.localizedDescription)")
        } else {
            
            delegate.bleScannerUpdate("Added service for advertisement")
        }
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!) {
        if(error == nil) {
            delegate.bleScannerUpdate("Your device is now a peripheral, advertising...")
        } else {
            delegate.bleScannerUpdate("Error in advertising: \(error.localizedFailureReason) \(error.localizedDescription)")
        }
    }
    
    func isAdvertising() -> Bool {
        return peripheralManager.isAdvertising
    }
    
    func stopAdvertise() {
        peripheralManager.stopAdvertising()
        delegate.bleScannerUpdate("Your device stopped advertising")
    }
    
    func connectToPeripheral(device: CBPeripheral) {
        delegate.bleScannerUpdate("Connecting to \(device.name)")
        delegate.bleScannerConnectedTo(device.name)
        bleManager.connectPeripheral(device, options: nil)

        peripheral = device
        peripheral.delegate = self
    }
    
    func disconnectWithPeripheral(peripheral: CBPeripheral) {
    
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!){
        
    }
    
    func getCharacteristics() {
        peripheral.discoverCharacteristics(nil, forService:selectedService)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didReceiveWriteRequests requests: [AnyObject]!) {
        for(var i = 0; i  < requests.count; i++) {
            let request: CBATTRequest = requests[0] as CBATTRequest
            let requested_data:NSData = request.value as NSData
            let dataString = NSString(data: requested_data, encoding: NSUTF8StringEncoding)
            delegate.bleScannerUpdate("Receiving a data \(dataString!)")
            peripheralManager.respondToRequest(request, withResult: CBATTError.Success)
        }
//        let request: CBATTRequest = requests[0] as CBATTRequest
//        let requested_data:NSData = request.value! as NSData
//        let dataString = NSString(data: requested_data, encoding: NSUTF8StringEncoding)
//        delegate.bleScannerUpdate("Receiving a data \(dataString)")
    //    peripheralManager.respondToRequest(<#request: CBATTRequest!#>, withResult: <#CBATTError#>)
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        deviceDelegate.bleScannerDiscovered(peripheral)
        delegate.bleScannerUpdate("Did found peripheral \(peripheral.name)")
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        delegate.bleScannerUpdateConnectionStatus(peripheral.name, status: "Connected")
        delegate.bleScannerUpdate("\(peripheral.name) is connected")
    }
    
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if(error != nil) {
            delegate.bleScannerUpdate("Error discovering services from \(peripheral.name)")
        } else {
            println("Discovered services")
            //List out the services available from the connected peripheral
            if(peripheral.services != nil) {
                for(var i = 0 ; i < peripheral.services.count; i++) {
                    var myService = peripheral.services[i] as CBService
                                println("Discovered \(myService.UUID)")
                    service.bleScannerDiscoveredService(myService)
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if(error == nil) {
            println("Discovered characteristics")
            for(var i = 0; i < service.characteristics.count; i++) {
                var myCharacteristic = service.characteristics[i] as CBCharacteristic
                println("Disvoered \(myCharacteristic.UUID)")
                characteristic.bleScannerDiscoveredCharacteristic(myCharacteristic)
            }
        } else {
            println("error in discovering characteristics: \(error.localizedDescription)")
        }
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        delegate.bleScannerUpdateConnectionStatus(peripheral.name, status: "Disconnected")
        delegate.bleScannerUpdate("Failed to connect with \(peripheral.name)")
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForDescriptor descriptor: CBDescriptor!, error: NSError!) {
        delegate.bleScannerUpdate("Did received descriptor input")
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        delegate.bleScannerUpdateConnectionStatus(peripheral.name, status: "Disconnected")
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        switch (central.state) {
        case CBCentralManagerState.PoweredOff:
            delegate.bleScannerUpdate("CoreBluetooth BLE hardware is powered off");
            break;
        case CBCentralManagerState.PoweredOn:
            delegate.bleScannerUpdate("CoreBluetooth BLE hardware is powered on and ready");
            break;
        case CBCentralManagerState.Resetting:
            delegate.bleScannerUpdate("CoreBluetooth BLE hardware is resetting");
            break;
        case CBCentralManagerState.Unauthorized:
            delegate.bleScannerUpdate("CoreBluetooth BLE state is unauthorized");
            break;
        case CBCentralManagerState.Unknown:
            delegate.bleScannerUpdate("CoreBluetooth BLE state is unknown");
            break;
        case CBCentralManagerState.Unsupported:
            delegate.bleScannerUpdate("CoreBluetooth BLE hardware is unsupported on this platform");
            break;
        default:
            break;
        }
    }
    
}
