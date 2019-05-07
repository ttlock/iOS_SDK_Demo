//
//  GatewayLockListModel.h
//  TTLockSourceCodeDemo
//
//  Created by 王娟娟 on 2019/4/29.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GatewayLockListModel : NSObject

@property (nonatomic,strong) NSNumber * lockId;

@property (nonatomic,strong) NSString * lockName;

@property (nonatomic,strong) NSString * lockMac;

@property (nonatomic,strong) NSNumber * rssi;

@property (nonatomic,strong) NSNumber * updateDate;

@end

NS_ASSUME_NONNULL_END
