## Minimum iOS Target:
iOS 9.0


## Minimum Xcode Version: 
Xcode 10.2 


## Installation

### By Cocoapods

First, add the following line to your Podfile:
<br>use_frameworks!
<br>target 'YourAppTargetName' do
<br>pod 'TTLock'
<br>pod 'TTLockDFU'（ If you need to upgrade devices into your application ）
<br>pod 'TTLockGateway'（ If you need to support first generation gateway ）
<br>end

Second, pod install



## Introduction

### TTLock
TTLock has been designed to communicate with devices by mobile phone bluetooth.
<br>TTGateway supports second generation gateway.

### TTLockDFU (Device Firmware Upgrade)
TTLockDFU has been designed to make it easy to upgrade devices into your application by mobile phone bluetooth.

### TTLockGateway
TTLockGateway supports first generation gateway.

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
