//
//  KeypadAddViewController.h
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/5/28.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LockModel.h"


@interface KeypadAddViewController : UITableViewController
- (instancetype)initWithLockModel:(LockModel *)lockModel;
@end


