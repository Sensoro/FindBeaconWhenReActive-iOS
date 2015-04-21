//
//  SENLocationManager.m
//  BeaconActive-ObjC
//
//  Created by skyming on 15/4/10.
//  Copyright (c) 2015年 Sensoro. All rights reserved.
//

#import "SENLocationManager.h"
#import <UIKit/UIKit.h>
#import <SensoroBeaconKit/SensoroBeaconKit.h>

@interface SENLocationManager ()<SBKBeaconManagerDelegate>

@end

@implementation SENLocationManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init{
    
    if(self = [super init])
    {
        _locationManager = [SBKBeaconManager sharedInstance];

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            //获取授权
            [_locationManager requestAlwaysAuthorization];
        }
        //设定代理
        _locationManager.delegate = self;
        //生成监测用的区域ID
        _monitorRegion = [SBKBeaconID beaconIDWithProximityUUID:[[NSUUID alloc]initWithUUIDString:@"46D06053-9FAD-483B-B704-E576735CE1A4"] major:0x23A2 minor:0x854D];
        
    }
    return self;
}


- (void)startMonitor:(BOOL)relaunch{
    
    if (!relaunch) {
        [_locationManager startRangingBeaconsWithID:_monitorRegion wakeUpApplication:YES];
        NSLog(@"Start monitor region!");
    }else{
        NSLog(@"During the relauch app, don't restart monitor region!");
        [_locationManager startRangingBeaconsWithID:_monitorRegion wakeUpApplication:NO];

    }
    _started = true;

}

- (void)stopMonitor{
    [_locationManager stopRangingBeaconsWithID:_monitorRegion];
    _started = false;
    NSLog(@"Stop monitor region!");
}

- (void)sendNotification:(NSString *)notify{
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.alertBody = notify;
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}


- (void)beaconManager:(SBKBeaconManager *)beaconManager didRangeNewBeacon:(SBKBeacon *)beacon{
   
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"YYYY/MM/dd HH:mm:ss";
    
    NSString *alertbody =[NSString stringWithFormat:@"Enter: %@ %@ %@ %@ %@ %@ %@",beacon.beaconID.proximityUUID.UUIDString, beacon.beaconID.major,beacon.beaconID.minor,beacon.batteryLevel,beacon.temperature,beacon.light,beacon.accelerometerCount];
    [self sendNotification:alertbody];
    
    NSLog(@"Enter: %@",now);
}

- (void)beaconManager:(SBKBeaconManager *)beaconManager beaconDidGone:(SBKBeacon *)beacon{
  
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"YYYY/MM/dd HH:mm:ss";
    
    NSString *alertbody =[NSString stringWithFormat:@"Exit: %@ %@ %@ %@ %@ %@ %@",beacon.beaconID.proximityUUID.UUIDString, beacon.beaconID.major,beacon.beaconID.minor,beacon.batteryLevel,beacon.temperature,beacon.light,beacon.accelerometerCount];
    [self sendNotification:alertbody];

    NSLog(@"Exit: %@",now);
}

- (void)beaconManager:(SBKBeaconManager *)beaconManager didDetermineState:(SBKRegionState)state forRegion:(SBKBeaconID *)region{
  
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"YYYY/MM/dd HH:mm:ss";
    
    switch (state) {
        case SBKRegionStateEnter:
        {
            NSString *alertbody =[NSString stringWithFormat:@"Enter region at %@",[formatter stringFromDate:now]];
            [self sendNotification:alertbody];
            NSLog(@"%@",alertbody);
        }
            break;
            
        case SBKRegionStateLeave:
        {
            NSString *alertbody =[NSString stringWithFormat:@"Exit region at %@",[formatter stringFromDate:now]];
            [self sendNotification:alertbody];
            NSLog(@"%@",alertbody);
        }
            break;
            
        case SBKRegionStateUnknown:
            NSLog(@"This region state was unknown!");
            break;
    }

    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            // Clean up any unfinished task business by marking where you
            // stopped or ending the task outright.
            [self sendNotification:@"后台任务结束"];
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
    }

}

- (void)beaconManager:(SBKBeaconManager *)beaconManager scanDidFinishWithBeacons:(NSArray *)beacons{
    
    NSLog(@"应用已被激活 %d",(int)beacons.count);
    
    SBKBeacon *beacon = nil;
    if (beacons.count > 0) {
        beacon = beacons[0];
        NSLog(@"Beacon: %@ %@", beacon,beacon.beaconID.debugDescription);
        NSString *alertbody =[NSString stringWithFormat:@"Beacon %@ %@ %@ %@ %@ %@ %@",beacon.beaconID.proximityUUID.UUIDString, beacon.beaconID.major,beacon.beaconID.minor,beacon.batteryLevel,beacon.temperature,beacon.light,beacon.accelerometerCount];
//        [self sendNotification:alertbody];
    }
    
}


@end
