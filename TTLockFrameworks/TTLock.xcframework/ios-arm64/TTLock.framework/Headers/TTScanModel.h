//
//  TTScanModel.h
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/11.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTScanModel : NSObject

@property (nonatomic, strong) NSString *lockName;
@property (nonatomic, strong) NSString *lockMac;
@property (nonatomic, assign) BOOL isInited;
@property (nonatomic, assign) BOOL isAllowUnlock;
@property (nonatomic, assign) BOOL isDfuMode;
@property (nonatomic, assign) NSInteger electricQuantity;
@property (nonatomic, strong) NSString * lockVersion;
@property (nonatomic, assign) TTLockSwitchState lockSwitchState;
@property (nonatomic, assign) NSInteger RSSI;
@property (nonatomic, assign) NSInteger oneMeterRSSI;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDictionary *advertisementData;

- (instancetype)initWithInfoDic:(NSDictionary *)infoDic;

@end


@interface TTWorkingModeTimeModel : NSObject

// The time when it becomes valid (minutes from 0 clock)
@property (nonatomic, assign) int startTime;
// The time when it becomes valid (minutes from 0 clock)
@property (nonatomic, assign) int endTime;
// 是否全天：1-是、2-否
@property (nonatomic, assign) int isAllDay;
// weekDays：1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
@property (nonatomic, strong) NSArray <NSNumber *>*weekDays;

@end

NS_ASSUME_NONNULL_END
