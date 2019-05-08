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
        [self.view showToast:LS(@"Success")];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        [self.view showToast:errorMsg];
    }];
```


### Dynamic frameworks are uploaded to AppStore
  ![](http://ikennd.ac/pictures/iTC-Unsupported-Archs.png)
  First step:Add a Run Script step to your build steps, put it after your step to embed frameworks, set it to use /bin/sh and enter the following script:
  
```objective-c
  APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"
  
  # This script loops through the frameworks embedded in the application and
  
  # removes unused architectures.
  
  find "$APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
  
  do
  
  FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
  
  FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
  
  echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"
  
  EXTRACTED_ARCHS=()
  
  for ARCH in $ARCHS
  
  do
  
  echo "Extracting $ARCH from $FRAMEWORK_EXECUTABLE_NAME"
  
  lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
  
  EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
  
  done
  
  echo "Merging extracted architectures: ${ARCHS}"
  
  lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
  
  rm "${EXTRACTED_ARCHS[@]}"
  
  echo "Replacing original executable with thinned version"
  
  rm "$FRAMEWORK_EXECUTABLE_PATH"
  
  mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"
  
  done
```
  
  The script will look through your built application’s Frameworks folder and make sure only the architectures you’re building for are present in each Framework.
  <br>Second step:Add the path of the imported dynamic Frameworks to Input Files
  ![](https://github.com/ttlock/iOS_TTLock_Demo/blob/master/TTLockDemo/images/0F50B0D2-30E0-44AD-9112-F18A6CB8BE4.png)
  
  Reference：
  http://ikennd.ac/blog/2015/02/stripping-unwanted-architectures-from-dynamic-libraries-in-xcode/
