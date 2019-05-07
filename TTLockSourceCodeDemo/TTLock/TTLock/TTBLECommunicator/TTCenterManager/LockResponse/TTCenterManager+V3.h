//
//  TTCenterManager+V3.h
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/4/17.
//  Copyright © 2019 wjj. All rights reserved.
//

#import "TTCenterManager.h"
#import "TTCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTCenterManager (V3)

-(void)lockV3HandleCommand:(TTCommand*)command;

@end

NS_ASSUME_NONNULL_END
