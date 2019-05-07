//
//  FirmwareUpdateModel.m
//  Sciener
//
//  Created by wjjxx on 17/1/23.
//  Copyright © 2017年 sciener. All rights reserved.
//

#import "FirmwareUpdateModel.h"

@implementation FirmwareUpdateModel
- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property{
    if ([property.name isEqualToString:@"firmwareInfo"]) {
        if ([oldValue isKindOfClass:[NSDictionary class]]) {
            _firmwareRevision = oldValue[@"firmwareRevision"];
            _modelNum = oldValue[@"modelNum"];
            _hardwareRevision = oldValue[@"hardwareRevision"];
        }
    }
    return oldValue;
}
@end
