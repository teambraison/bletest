//
//  PeripheralServicesViewController.swift
//  BLETest
//
//  Created by Titus Cheng on 12/6/14.
//  Copyright (c) 2014 Braison. All rights reserved.
//

import Foundation
import UIKit

import CoreBluetooth

class PeripheralServicesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BLEScannerServiceDiscoveryDelegate
{
    
    @IBOutlet weak var servicesViewController: UITableView!
    var bleManager: BLEScanner!
    
    var serviceList: [CBService]!
    
    override func viewDidLoad() {
        bleManager = BLEScanner.sharedInstance()
        bleManager.service = self
        servicesViewController.delegate = self
        servicesViewController.dataSource = self
        serviceList = []
    }
    
    
    override func viewDidAppear(animated: Bool) {
        if(bleManager.selectedCharacteristic == nil) {
            bleManager.discoverServices()
        } else {
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    func bleScannerDiscoveredService(service: CBService) {
        serviceList.append(service)
        servicesViewController.reloadData()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        bleManager.chooseThisService(serviceList[indexPath.row])
        
        let characteristicVC: PeripheralCharacteristicsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("characteristics") as PeripheralCharacteristicsViewController
        self.presentViewController(characteristicVC, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        let service = serviceList[indexPath.row] as CBService
        cell.textLabel?.text = "\(service.UUID)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceList.count
    }
    
    
    
}
