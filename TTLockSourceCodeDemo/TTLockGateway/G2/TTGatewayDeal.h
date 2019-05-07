//
//  TTGatewayDeal.h
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/3/5.
//  Copyright © 2019 wjj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTLockGateway.h"
#import "TTGatewayInitModel.h"


@interface TTGatewayDeal : NSObject

@property (nonatomic,strong) CBCentralManager * manager;
@property (nonatomic,strong) CBPeripheral * activePeripheral;
@property (nonatomic,strong) NSMutableDictionary *bleScanDict;
@property (nonatomic,strong) NSString  *currentLockMac;//当前操作的
@property (nonatomic,strong) NSString  *toConnectLockMac;//需要去连接的
@property (nonatomic,strong) NSMutableDictionary * gatewayDeviceInfoDic;
@property (nonatomic,assign) BOOL isConnected;//是否已连接
@property (nonatomic,strong) NSMutableDictionary *bleBlockDict;
@property (nonatomic,strong) NSMutableArray *WiFiArr;
@property (nonatomic,strong) TTGatewayInitModel *gatewayModel;

+ (instancetype)shareInstance;
- (void)startScanGatewayWithBlock:(TTGatewayScanBlock)block;
- (void)stopScanGateway;
- (void)connectGatewayWithGatewayMac:(NSString *)gatewayMac block:(TTGatewayConnectBlock)block;
- (void)disconnectGatewayWithGatewayMac:(NSString *)gatewayMac block:(TTGatewayBlock)block;
- (void)scanWiFiByGatewayWithBlock:(TTGatewayScanWiFiBlock)block;
- (void)initializeGatewayWithInfoDic:(NSDictionary *)infoDic block:(TTInitializeGatewayBlock)block;
- (void)upgradeGatewayWithGatewayMac:(NSString *)gatewayMac block:(TTGatewayBlock)block;

@end
