//
//  TTCenterManager+Common.h
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/4/16.
//  Copyright © 2019 wjj. All rights reserved.
//

#import "TTCenterManager.h"
#import "TTCommand.h"

@interface TTCenterManager (Common)

- (void)onAddAdminWithCommand:(TTCommand*)command timestamp:(long long)timeStr pwdInfo:(NSString*)pwdInfo  Characteristic:(long long)characteristic deviceInfoDic:(NSMutableDictionary*)deviceInfoDic;
- (void)onTTErrorWithData:(Byte*)data version:(NSString *)version;
- (void)onTTError:(TTError)error command:(int)command;
- (void)onGetOperateLog:(BOOL)isFinish;
-(int)getPower;

@end
