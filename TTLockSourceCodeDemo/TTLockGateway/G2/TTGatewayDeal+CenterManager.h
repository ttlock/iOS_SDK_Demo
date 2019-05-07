//
//  TTGatewayDeal+CenterManager.h
//  TTLockSourceCodeDemo
//
//  Created by 王娟娟 on 2019/4/28.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "TTGatewayDeal.h"
#import <CoreBluetooth/CoreBluetooth.h>
NS_ASSUME_NONNULL_BEGIN

@interface TTGatewayDeal (CenterManager)<CBCentralManagerDelegate,CBPeripheralDelegate>

-(void)createCentralManager;
- (void)startScanLock;
-(void)stopScanLock;
- (void)connectPeripheralWithLockMac:(NSString *)lockMac;
- (void)cancelConnectPeripheralWithLockMac:(NSString *)lockMac;

@end

NS_ASSUME_NONNULL_END
