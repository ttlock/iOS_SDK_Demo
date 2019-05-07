//
//  ICCardModel.h
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/22.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ICCardModel : NSObject
@property (nonatomic, strong) NSNumber *cardId;
@property (nonatomic, strong) NSNumber *lockId;
@property (nonatomic, strong) NSString *cardNumber;
@property (nonatomic, strong) NSString *cardName;
@property (nonatomic, assign) long long startDate;
@property (nonatomic, assign) long long endDate;
@property (nonatomic, assign) long long createDate;
@end

NS_ASSUME_NONNULL_END
