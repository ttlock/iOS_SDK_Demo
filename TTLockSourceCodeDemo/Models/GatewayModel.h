//
//  GatewayModel.h
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/26.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,GatewayType) {
    GatewayG1 = 1,
    GatewayG2
};

@interface GatewayModel : NSObject
@property (nonatomic, strong) NSNumber *gatewayId;
@property (nonatomic, strong) NSString *gatewayMac;
@property (nonatomic, assign) GatewayType gatewayVersion;
@property (nonatomic, strong) NSString *networkName;
@property (nonatomic, strong) NSNumber *lockNum;
@property (nonatomic, assign) BOOL isOnline;
//
@property (nonatomic, assign) BOOL isInited;
@property (nonatomic, strong) NSString *gatewayName;
@property (nonatomic, assign) NSInteger RSSI;
@property (nonatomic, strong) NSDate  *searchTime;
@end


