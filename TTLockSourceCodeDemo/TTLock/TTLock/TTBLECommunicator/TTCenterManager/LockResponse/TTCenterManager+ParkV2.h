//
//  TTCenterManager+ParkV2.h
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/4/16.
//  Copyright © 2019 wjj. All rights reserved.
//

#import "TTCenterManager.h"
#import "TTCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTCenterManager (ParkV2)

-(void)parkV2HandleCommand:(TTCommand*)command;

@end

NS_ASSUME_NONNULL_END
