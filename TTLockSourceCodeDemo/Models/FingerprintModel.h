//
//  FingerprintModel.h
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/22.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FingerprintModel : NSObject
@property (nonatomic, strong) NSNumber *fingerprintId;
@property (nonatomic, strong) NSNumber *lockId;
@property (nonatomic, strong) NSString *fingerprintNumber;
@property (nonatomic, strong) NSString *fingerprintName;
@property (nonatomic, assign) long long startDate;
@property (nonatomic, assign) long long endDate;
@property (nonatomic, assign) long long createDate;
@end

NS_ASSUME_NONNULL_END
