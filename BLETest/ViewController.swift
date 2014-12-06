//
//  ViewController.swift
//  BLETest
//
//  Created by Titus Cheng on 12/5/14.
//  Copyright (c) 2014 Braison. All rights reserved.
//

import UIKit

import CoreBluetooth

class ViewController: UIViewController, BLEScannerDelegate, UITextFieldDelegate  {

    @IBOutlet weak var dataTextField: UITextField!
    @IBOutlet weak var advertisementSwitch: UISwitch!
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var deviceNameButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    var bleManager: BLEScanner!

    override func viewDidLoad() {
        super.viewDidLoad()
        bleManager = BLEScanner.sharedInstance()
        advertisementSwitch.setOn(false, animated: false)
        // Do any additional setup after loading the view, typically from a nib.
        println(UIDevice.currentDevice().identifierForVendor)
        bleManager.delegate = self
        
        dataTextField.delegate = self
        
        sendData.addTarget(self, action: "sendData:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    @IBOutlet weak var sendData: UIButton!
    
    
    @IBAction func sendData(sender: AnyObject) {
        if(countElements(dataTextField.text) > 0) {
//            var characteristicUUID = CBUUID(string: "fff1")
//            var characteristic = CBMutableCharacteristic(type: characteristicUUID, properties: CBCharacteristicProperties.Write, value: dataTextField.text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), permissions: CBAttributePermissions.Writeable)
//            peripheral.writeValue(dataTextField.text!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
            bleManager.sendData(dataTextField.text)
        }
        dataTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    func bleScannerUpdateConnectionStatus(deviceName: String, status: String) {
        statusLabel.text = status
        deviceNameButton.setTitle(deviceName, forState: UIControlState.Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        bleManager.delegate = self
        if(bleManager != nil) {
            if(bleManager.peripheral != nil) {
                deviceNameButton.setTitle(bleManager.peripheral.name, forState: UIControlState.Normal)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {

    }
    
    func bleScannerConnectedTo(deviceName: String) {
        if(deviceName != "") {
            deviceNameButton.setTitle(deviceName, forState: UIControlState.Normal)
            statusLabel.text = "Connected"
        }
    }
    
//    func bleScannerDiscovered(peripherals: CBPeripheral) {
//        
//    }
    
    func bleScannerUpdate(updates: String) {
        updateLog(updates)
    }
    
    @IBAction func advertiseSwitched(sender: AnyObject) {
        var advertiseOn:UISwitch = sender as UISwitch
        if(advertiseOn.on) {
            bleManager.startAdvertise(UIDevice.currentDevice().identifierForVendor.UUIDString)
        } else {
            bleManager.stopAdvertise()
        }
    }
    
    func bleScannerDidUpdateAdvertisementStatus(isOn: Bool) {
        advertisementSwitch.setOn(isOn, animated: true)
    }
    
    func updateDeviceName(newName: String) {
        deviceNameButton.setTitle(newName, forState: UIControlState.Normal)
    }
    
    
    //Log functions
    
    func updateLog(result: String) {
        logTextView.text = logTextView.text + "\n" + result
    }
    
    func clearLog() {
        logTextView.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

