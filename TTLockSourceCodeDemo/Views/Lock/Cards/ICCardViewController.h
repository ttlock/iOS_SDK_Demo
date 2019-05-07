//
//  ICCardViewController.h
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/22.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICCardModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ICCardViewController : UITableViewController
//add card
- (instancetype)initWithLockModel:(LockModel *)lockModel;

//modify card
- (instancetype)initWithLockModel:(LockModel *)lockModel cardModel:(ICCardModel *)cardModel;
@end

NS_ASSUME_NONNULL_END
