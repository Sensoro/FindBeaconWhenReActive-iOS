# FindBeaconWhenReActive-iOS
<<<<<<< HEAD
用于演示并测试App被Kill后激活，重启后激活，修改语言后激活等表现是否可以拿到Beacon的UMM、传感器数据等。

##目录内容
1. BeaconSDKActiveData-Swift，使用苹果标准的API实现的后台唤醒后是否可以获取Beacon数据。
2. SensoroSDKActiveData-iOS，使用Sensoro SDK实现的后台唤醒后是否可以获取Beacon数据。

##测试环境

* 测试机型：iPhone 6
* 系统版本：iOS 8.3
* iBeacon配置：
 	* UUID : 46D06053-9FAD-483B-B704-E576735CE1A3
 	* Major & Minor : 任意
	* 也可以使用配置工具扫描App中的二维码进行配置。

##测试: 

####Kill掉App后，进入离开区域，测试Beacon设备数据。

UMM ：46D06053-9FAD-483B-B704-E576735CE1A3|0x23A2|0x854D

型号 | 电量 | 温度 | 亮度| 加速度
--- | ---- | --- | ---- | ---- 
A0  | 0.92 |null | null | null
A0  | 0.93 |null | null | null
B0  | 0.71 | 18  | 13.95| 0
B0  | 0.71 | 18  | 18.08| 3
C0  | 0.99 | 23  | null | 10 
C0  | 0.99 | 21  | null | 12 

####设定语言后的重启。

与Kill掉App效果基本相同。

####重启后，进入离开区域，测定Beacon设备数据。

UMM ：46D06053-9FAD-483B-B704-E576735CE1A3|0x23A2|0x854D

型号 | 电量 | 温度 | 亮度| 加速度
--- | ---- | --- | ---- | ---- 
A0  | 0.94 |null |null|null
A0  | 0.87 |null |null|null
B0  | 0.55 | 18  | 37.62| 0
B0  | 0.55 | 18  | 37.44| 0
C0  | 0.99 | 23  | null | 10 
C0  | 0.99 | 20  | null | 17 

####注意事项
* 唤醒后获取Beacon数据测试代码是基于[Beacon-Active-iOS](https://github.com/Sensoro/Beacon-Active-iOS)

* 唤醒后在 startMonitor: 内添加如下代码

```Object-C
 [_locationManager startRangingBeaconsWithID:_monitorRegion wakeUpApplication:NO];

```
* 在 beaconManager： didDetermineState：forRegion：添加

```Object-C
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            // Clean up any unfinished task business by marking where you
            // stopped or ending the task outright.
            [self sendNotification:@"后台任务结束"];
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
    }
```
=======
>>>>>>> f67e7d66bfdde31191627337bb4a5a8beea0cb05
