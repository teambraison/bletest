//
//  PeripheralCharacteristicsIViewController.swift
//  BLETest
//
//  Created by Titus Cheng on 12/6/14.
//  Copyright (c) 2014 Braison. All rights reserved.
//

import Foundation
import UIKit

import CoreBluetooth

class PeripheralCharacteristicsViewController:UIViewController, UITableViewDataSource, UITableViewDelegate, BLEScannerCharacteristicDiscoveryDelegate
{
    @IBOutlet weak var characteristicsTableView: UITableView!
    var bleManager: BLEScanner!
    var characteristicList:[CBCharacteristic]!
    override func viewDidLoad() {
        characteristicsTableView.delegate = self
        characteristicsTableView.dataSource = self
        bleManager = BLEScanner.sharedInstance()
        characteristicList = []
    }
    
    override func viewDidAppear(animated: Bool) {
        bleManager.characteristic = self
        bleManager.getCharacteristics()
    }
    
    func bleScannerDiscoveredCharacteristic(theCharacteristic: CBCharacteristic) {
        characteristicList.append(theCharacteristic)
        characteristicsTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        var theData: CBCharacteristic = characteristicList[indexPath.row] as CBCharacteristic
        cell.textLabel?.text = "\(theData.UUID)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        bleManager.selectedCharacteristic = characteristicList[indexPath.row]
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characteristicList.count
    }
}
