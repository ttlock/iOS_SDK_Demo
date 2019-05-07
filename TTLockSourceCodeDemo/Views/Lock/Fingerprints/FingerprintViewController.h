//
//  FingerprintViewController.h
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/22.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FingerprintModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FingerprintViewController : UITableViewController
//add
- (instancetype)initWithLockModel:(LockModel *)lockModel;

//modify
- (instancetype)initWithLockModel:(LockModel *)lockModel fingerprintModel:(FingerprintModel *)fingerprintModel;
@end

NS_ASSUME_NONNULL_END
