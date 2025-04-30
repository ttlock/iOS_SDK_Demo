## Developers Email list
ttlock-developers-email-list@googlegroups.com

## Development environment
Minimum iOS Target: iOS 9.0
<br>Minimum Xcode Version: Xcode 14

## Installation

### By Cocoapods

First, add the following line to your Podfile:
<br>use_frameworks!
<br>target 'YourAppTargetName' do
<br>pod 'TTLock' #（Required）
<br>pod 'TTLockDFU'  #（Optional）（ If you need to upgrade devices into your application ）
<br>end

Second, pod install

### By Manually

1、Drag the corresponding frameworks into the project.(Check Target->General->Frameworks, Libraries and Embedded Content contains the frameworks）
<br>2、Find Target->Build Phases -> Link Binary With Libraries ,add CoreBluetooth.framework.
<br>3、Important! Find Target->Build Settings -> Linking -> Other Linker Flags ,add -ObjC（If it already exists, there is no need to add it.）

## Introduction

### TTLock
TTLock has been designed to communicate with devices by mobile phone bluetooth.
<br>TTGateway supports second generation gateway.
<br>TTUtil provides methods to use specialValue and get type of lock.

### TTLockDFU (Device Firmware Upgrade)
TTLockDFU has been designed to make it easy to upgrade devices into your application by mobile phone bluetooth.


## Usage

### TTLock Usage
Initialize TTLock in the method{ didFinishLaunchingWithOptions} in AppDelegate (please do not call it in an asynchronous thread)

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

     [TTLock setupBluetooth:^(TTBluetoothState state) {
        NSLog(@"##############  TTLock is working, bluetooth state: %ld  ##############",(long)state);
    }];
    return YES;
}
```
### Scene: Unlock 
```objective-c
 [TTLock controlLockWithControlAction:TTControlActionUnlock lockData:lockData success:^(long long lockTime, NSInteger electricQuantity, long long uniqueId) {
        NSLog(@"##############  Unlock successed power: %ld  ##############",(long)electricQuantity);
    } failure:^(TTError errorCode, NSString *errorMsg) {
        NSLog(@"##############  Unlock failed errorMsg: %@  ##############",errorMsg);
    }];
```
If you want to get log and set time immediately after unlocking, you can do the following:

```objective-c
- (void)unlockAndGetLogAndSetTime{

     //unlock
    [TTLock controlLockWithControlAction:TTControlActionUnlock lockData:lockData success:^(long long lockTime, NSInteger electricQuantity, long long uniqueId) {
        NSLog(@"##############  Unlock successed power: %ld  ##############",(long)electricQuantity);
    } failure:^(TTError errorCode, NSString *errorMsg) {
        NSLog(@"##############  Unlock failed errorMsg: %@  ##############",errorMsg);
    }];
    
     //get log
    [TTLock getOperationLogWithType:TTOperateLogTypeLatest lockData:lockData success:^(NSString *operateRecord) {
        NSLog(@"##############  Log: %@  ##############",operateRecord);
    } failure:^(TTError errorCode, NSString *errorMsg) {
        NSLog(@"##############  Get log failed errorMsg: %@  ##############",errorMsg);
    }];

     //set time
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    [TTLock setLockTimeWithTimestamp:timestamp lockData:lockData success:^{
        NSLog(@"##############  Set time successed  ##############");
    } failure:^(TTError errorCode, NSString *errorMsg) {
        NSLog(@"##############  Set time failed errorMsg: %@  ##############",errorMsg);
    }];
}

```
### How to use FeatureValue
```objective-c
 BOOL isSupportPasscode = [TTUtil isSupportFeature:TTLockFeatureValuePasscode lockData:_lockModel.lockData];
```
```objective-c
 BOOL isSupportICCard = [TTUtil isSupportFeature:TTLockFeatureValueICCard lockData:_lockModel.lockData];
```
```objective-c
 BOOL isSupportFingerprint = [TTUtil isSupportFeature:TTLockFeatureValueFingerprint lockData:_lockModel.lockData];
```
