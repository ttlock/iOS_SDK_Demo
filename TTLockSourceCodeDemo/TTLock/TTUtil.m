//
//  TTUtil.m
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/4/22.
//  Copyright © 2019 wjj. All rights reserved.
//

#import "TTUtil.h"
#import "TTDataTransformUtil.h"
#import "TTCenterManager.h"

@implementation TTUtil

+ (BOOL)lockSpecialValue:(long long)specialValue suportFunction:(TTLockSpecialFunction)function{
    return (specialValue & function) > 0;
}

+ (TTLockType)getLockTypeWithLockVersion:(NSDictionary *)lockVersion{
    
    int protocolType = [lockVersion[@"protocolType"] intValue];
    int protocolVersion = [lockVersion[@"protocolVersion"] intValue];
    int scene = [lockVersion[@"scene"] intValue];
    if (protocolType == 10) {
        return TTLockTypeV2ParkingLock;
    }
    if (protocolType == 5){
        if (protocolVersion == 1) {
            return TTLockTypeV2;
        }
        if (protocolVersion == 4 && scene == 1) {
            return TTLockTypeV2Scene1;
        }
        if (protocolVersion == 4 && scene == 2) {
            return TTLockTypeV2Scene2;
        }
        if (protocolVersion == 3) {
            if (scene == GateLockSceneType) {
                return TTLockTypeGateLock;
            }
            if (scene == SafeLockSceneType) {
                return TTLockTypeSafeLock;
            }
            if (scene == BicycleLockSceneType) {
                return TTLockTypeBicycleLock;
            }
            if (scene == ParkSceneType) {
                return TTLockTypeParkingLock;
            }
            if (scene == PadLockSceneType) {
                return TTLockTypePadLock;
            }
            if (scene == CylinderLockSceneType) {
                return TTLockTypeCylinderLock;
            }
            if (scene == RemoteControlFourButtonType) {
                return TTLockTypeRemoteControl;
            }
            if (scene == HotelSafeLockSceneType) {
                return TTLockTypeHotelLock;
            }
            return TTLockTypeV3;
        }
        
    }
    //不支持
    return -1;
}


@end
