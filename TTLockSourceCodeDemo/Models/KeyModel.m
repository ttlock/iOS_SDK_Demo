//
//  KeyModel.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/19.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "KeyModel.h"

@implementation KeyModel
- (BOOL)isAdminEKey{
    return _userType == 110301;
}
@end
