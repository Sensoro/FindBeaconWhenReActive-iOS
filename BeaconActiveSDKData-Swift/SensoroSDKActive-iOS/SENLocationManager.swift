//
//  SENLocationManager.swift
//  SensoroSDKActive-iOS
//
//  Created by David Yang on 15/4/8.
//  Copyright (c) 2015年 Sensoro. All rights reserved.
//

import UIKit
import CoreLocation
import SensoroBeaconKit

private let _sharedInstance = SENLocationManager();

class SENLocationManager: NSObject, SBKBeaconManagerDelegate {
    
    class var sharedInstance : SENLocationManager {
        return _sharedInstance;
    }

    var started = false;
    var monitorRegion : SBKBeaconID!;

    var alertbody: NSMutableString? = nil;
    
    private override init(){
        
        super.init();

        //设定代理
        SBKBeaconManager.sharedInstance().delegate = self;
        //获取授权
        SBKBeaconManager.sharedInstance().requestAlwaysAuthorization();
        //生成监测用的区域ID
        monitorRegion = SBKBeaconID(proximityUUID: NSUUID(UUIDString: "46D06053-9FAD-483B-B704-E576735CE1A3"));
    }
    
    func startMonitor( relaunch : Bool ){
        if relaunch == false {
            SBKBeaconManager.sharedInstance().startRangingBeaconsWithID(monitorRegion, wakeUpApplication: true);
            NSLog("Start monitor region!");
        }else{
            NSLog("During the relauch app, don't restart monitor region!");
            SBKBeaconManager.sharedInstance().startRangingBeaconsWithID(monitorRegion, wakeUpApplication: false);
        }
        started = true;
    }
    
    
    func stopMonitor(){
        SBKBeaconManager.sharedInstance().stopRangingBeaconsWithID(monitorRegion);
        started = false;
        NSLog("Stop monitor region!");
    }
    
    func sendNotification(notify : String){
        var notification = UILocalNotification()
        notification.alertBody = notify
        
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func checkUnwrapping(sensorData:NSNumber?){
        
        if let info = sensorData{
            alertbody?.appendFormat("% @ ", sensorData!);
        }
    }
    
    // MARK: SBKBeaconManagerDelegate
    func beaconManager(beaconManager: SBKBeaconManager!, didRangeNewBeacon beacon: SBKBeacon!) {
        let now = NSDate();
        let formatter = NSDateFormatter();
        formatter.dateFormat = "YYYY/MM/dd HH:mm:ss";
        //NSLog("Enter a beacon at \(formatter.stringFromDate(now))");
    }
    
    func beaconManager(beaconManager: SBKBeaconManager!, beaconDidGone beacon: SBKBeacon!) {
        let now = NSDate();
        let formatter = NSDateFormatter();
        formatter.dateFormat = "YYYY/MM/dd HH:mm:ss";
        //NSLog("Leave a region at \(formatter.stringFromDate(now))");
    }
    
    func beaconManager(beaconManager: SBKBeaconManager!, scanDidFinishWithBeacons beacons: [AnyObject]!) {
        //NSLog("Periodically call for scanDidFinishWithBeacons");
        if(beacons.count > 0){
            var beacon:SBKBeacon! = beacons[0] as? SBKBeacon;
            alertbody = NSMutableString(format: "Beacon %@ %@ %@ ", beacon!.beaconID.proximityUUID.UUIDString,beacon!.beaconID.major,beacon!.beaconID.minor);
         
            self.checkUnwrapping(beacon!.batteryLevel);
            self.checkUnwrapping(beacon!.temperature);
            self.checkUnwrapping(beacon!.light);
            self.checkUnwrapping(beacon!.accelerometerCount);
            
            self.sendNotification("\(alertbody)");
        }
    }
    
    func beaconManager(beaconManager: SBKBeaconManager!, didDetermineState state : SBKRegionState, forRegion region : SBKBeaconID!) {
        
        switch state {
        case .Enter:
            let now = NSDate();
            let formatter = NSDateFormatter();
            formatter.dateFormat = "YYYY/MM/dd HH:mm:ss";
            sendNotification("Enter region at \(formatter.stringFromDate(now))");
            NSLog("Enter region at \(formatter.stringFromDate(now))");
        case .Leave:
            let now = NSDate();
            let formatter = NSDateFormatter();
            formatter.dateFormat = "YYYY/MM/dd HH:mm:ss";
            sendNotification("Exit  region at \(formatter.stringFromDate(now))");
            NSLog("Exit  region at \(formatter.stringFromDate(now))");
        case .Unknown:
            NSLog("This region state was unknown!");
        }
        
        var bgTask : UIBackgroundTaskIdentifier? = nil;
        bgTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
            self.sendNotification("后台任务结束");
            if let bgTaskInner = bgTask {
                UIApplication.sharedApplication().endBackgroundTask(bgTaskInner);
                bgTask = UIBackgroundTaskInvalid;
            }
        }

    }
    
    
}


