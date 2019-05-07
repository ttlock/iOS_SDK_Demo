//
//  TTGatewayDeal+HandleResponse.h
//  TTLockSourceCodeDemo
//
//  Created by 王娟娟 on 2019/4/28.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "TTGatewayDeal.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTGatewayDeal (HandleResponse)


- (void)handleCommandResponse:(Byte *)decryptData dataResponse:(Byte *)dataResponse;
- (void)responseData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
