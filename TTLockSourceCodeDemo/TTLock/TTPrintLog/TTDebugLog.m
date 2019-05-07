//
//  TTDebugLog.m
//  TTLockDemo
//
//  Created by wjjxx on 16/9/6.
//  Copyright © 2016年 wjj. All rights reserved.
//

#import "TTDebugLog.h"
#import "TTLockApi.h"

@implementation TTDebugLog
+(void)log:(NSString*)log{
    
    if ([[TTLockApi sharedInstance]isPrintLog]) {
        
        NSLog(@"%@",log);
        
    }
}
@end
