//
//  BLEScannerViewController.swift
//  BLETest
//
//  Created by Titus Cheng on 12/5/14.
//  Copyright (c) 2014 Braison. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class BLEScannerViewController: UIViewController, BLEScannerDeviceDiscoveryDelegate, UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var peripheralTableView: UITableView!
    var bleManager: BLEScanner!
    var peripheralList: [CBPeripheral]!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Connect tableview
        peripheralTableView.delegate = self;
        peripheralTableView.dataSource = self;
        peripheralList = []
        
        initialSetup()
        
    }
    
    func initialSetup() {
        bleManager = BLEScanner.sharedInstance()
        bleManager.deviceDelegate = self
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = UITableViewCell()
        cell.textLabel?.text = peripheralList[indexPath.row].name
        cell.detailTextLabel?.text = peripheralList[indexPath.row].description
        return cell
    }
    
    override func viewWillAppear(animated: Bool) {
        backButton.addTarget(self, action: "backToPreviousScreen", forControlEvents: UIControlEvents.TouchUpInside)
        activityIndicator.hidden = true
        
        if(bleManager == nil) {
            bleManager = BLEScanner.sharedInstance()
        }
        bleManager.deviceDelegate = self
        bleManager.startScan()
    }
    
    override func viewWillDisappear(animated: Bool) {
        activityIndicator.stopAnimating()
    }
    
    
    //Selecting peripheral
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        bleManager.connectToPeripheral(peripheralList[indexPath.row])
        var serviceVC: PeripheralServicesViewController = self.storyboard?.instantiateViewControllerWithIdentifier("services") as PeripheralServicesViewController
        self.presentViewController(serviceVC, animated: true, completion: nil)
    }

    
    override func viewDidAppear(animated: Bool) {
        if(bleManager.selectedService == nil) {
                activityIndicator.hidden = true
        } else {
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        bleManager.stopScan()
    }
    
    @IBAction func scanForDevices(sender: AnyObject) {
        bleManager.startScan()
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
//    func bleScannerUpdate(updates: String) {
//        if(updates == "Start scanning") {
//            activityIndicator.hidden = false
//            activityIndicator.startAnimating()
//        }
//        println(updates)
//    }
    
    func backToPreviousScreen() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func bleScannerDiscovered(peripherals: CBPeripheral) {
//        if(peripheralList.count == 0) {
            peripheralList.append(peripherals)
//        } else {
//            for(var i = 0; i < peripheralList.count; i++) {
//                if(peripheralList[i].description == peripherals.description) {
//                    peripheralList[i] = peripherals
//                }
//            }
//        }
        println("Discovered new peripheral \(peripherals.name)")
        peripheralTableView.reloadData()
    }
    

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralList.count
    }
    


}
