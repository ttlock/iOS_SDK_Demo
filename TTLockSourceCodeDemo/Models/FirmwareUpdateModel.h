//
//  FirmwareUpdateModel.h
//  Sciener
//
//  Created by wjjxx on 17/1/23.
//  Copyright © 2017年 sciener. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FirmwareUpdateModel : NSObject
@property (nonatomic,strong) NSNumber * needUpgrade;
@property (nonatomic,strong) NSString * modelNum;
@property (nonatomic,strong) NSString * hardwareRevision;
@property (nonatomic,strong) NSString * firmwareRevision;
@property (nonatomic,strong) NSString * version;
@property (nonatomic,strong)NSDictionary * firmwareInfo;


@end
