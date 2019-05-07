//
//  BaseGatewayAddViewController.h
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/26.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GatewayModel.h"

@interface BaseGatewayAddViewController : UITableViewController
- (instancetype)initWithGatewayType:(GatewayType)gatewayType;

- (void)gatewayConfigWiFi:(NSString *)wifi wifiPassword:(NSString *)wifiPasscord gatewayName:(NSString *)gatewayName;

@end


