//
//  Gateway2ViewController.h
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/26.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Gateway2AddViewController : UITableViewController
- (instancetype)initWithWiFi:(NSString *)wifi wifiPassword:(NSString *)wifiPassword gatewayName:(NSString *)gatewayName;
@end

NS_ASSUME_NONNULL_END
