//
//  TTGatewayInitModel.h
//  TTLockSourceCodeDemo
//
//  Created by 王娟娟 on 2019/4/28.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTGatewayInitModel : NSObject
//key:SSID      type:NSString
//key:wifiPwd   type:NSString  (不能有中文）
//key:uid       type:NSNumber
//key:userPwd   type:NSString
//key:companyId  type:NSNumber
//key:branchId  type:NSNumber
//key:debugMode type:NSNumber
//key:plugName  type:NSString
//key:ishoneywell  type:NSNumber
@property (nonatomic,strong)NSString *SSID;
@property (nonatomic,strong)NSString *wifiPwd;
@property (nonatomic,strong)NSNumber *uid;
@property (nonatomic,strong)NSString *userPwd;
@property (nonatomic,strong)NSString *companyId;
@property (nonatomic,strong)NSNumber *branchId;
@property (nonatomic,assign)BOOL debugMode;
@property (nonatomic,strong)NSString *plugName;
@property (nonatomic,assign)BOOL ishoneywell;

@end

NS_ASSUME_NONNULL_END
