//
//  TTSmartLinkDeal.m
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/3/5.
//  Copyright © 2019 wjj. All rights reserved.
//

#import "TTSmartLinkDeal.h"
#import "HFSmartLink.h"
#import "TTWifiGCDAsyncSocket.h"
#import "TTWIfiMD5.h"
#import "TTWifiUtils.h"
#import "TTLockGateway.h"

@interface TTSmartLinkDeal ()<GCDAsyncSocketDelegate>
@property (nonatomic,strong) HFSmartLinkDeviceInfo *devInfo;
@property (nonatomic,strong) NSString *wifiMac;
@property (nonatomic,strong)NSString *wifiIp;
@property (nonatomic,strong) TTWifiGCDAsyncSocket *socket;
@property (nonatomic,assign)int isSuccess; //读写是否成功 0 表示默认  1 表示失败 2 表示成功 3 表示连接成功
@property (nonatomic,assign)int uid;
@property (nonatomic,strong)NSString *userPwd;
@property (nonatomic,strong)NSString *wifiPwd;
@property (nonatomic,assign)long long companyId;
@property (nonatomic,assign)long long branchId;
@property (nonatomic,copy)TTSmartLinkProcessBlock  ProcessBlock;
@property (nonatomic,copy)TTSmartLinkSuccessBlock  SuccessBlock;
@property (nonatomic,copy)TTSmartLinkFailBlock  FailBlock;

@end

@implementation TTSmartLinkDeal

- (void)setupWifiBoxWithUid:(int)uid userPwd:(NSString*)userPwd wifiPwd:(NSString*)wifiPwd SSID:(NSString*)SSID companyId:(long long)companyId branchId:(long long)branchId  processblock:(TTSmartLinkProcessBlock)pblock successBlock:(TTSmartLinkSuccessBlock)sblock failBlock:(TTSmartLinkFailBlock)fblock{
    self.uid = uid;
    self.userPwd = userPwd;
    self.wifiPwd = wifiPwd;
    self.companyId = companyId;
    self.branchId = branchId;
    self.ProcessBlock = pblock;
    self.SuccessBlock = sblock;
    self.FailBlock = fblock;
    self.isSuccess = 0;
    [[HFSmartLink shareInstence] startWithSSID:SSID
                                           Key:wifiPwd
                                       withV3x:YES
                                  processblock:^(NSInteger process) {
                                      if(self.isSuccess == 0){
                                          if (self.ProcessBlock) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  self.ProcessBlock(process);
                                              });
                                          }
                                      }
                                      
                                  } successBlock:^(HFSmartLinkDeviceInfo *dev) {
                                      
                                      self.wifiMac = dev.mac;
                                      self.isSuccess = 3;
                                      self.wifiIp = dev.ip;
                                      [self connectToServer:dev.ip];
                                      
                                  } failBlock:^(NSString *failmsg) {
                                      self.isSuccess = 1;
                                      if (self.FailBlock) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              self.FailBlock();
                                          });
                                          
                                      }
                                  } endBlock:^(NSDictionary *deviceDic) {
                                      
                                  }];
}
#pragma mark TCP 连接 插座盒子
- (void)connectToServer:(NSString *)host {
    // 1.与服务器通过三次握手建立连接
    int port = 8899;
    //创建一个socket对象
    _socket = [[TTWifiGCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    NSError *error = nil;
    [_socket connectToHost:host onPort:port error:&error];
    
    if (error) {
        if (self.FailBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.FailBlock();
            });
        }
    }
}
#pragma mark -socket的代理
#pragma mark 连接成功
-(void)socket:(TTWifiGCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    //连接成功 与网关通信中
    
    Byte UID[4]= {0x0,0x0,0x0,0x0};
    //用户ID 4byte
    NSString *uidHexStr = [NSString stringWithFormat:@"%08x",self.uid];
    NSData *uidData = [TTWifiUtils DataFromHexStr:uidHexStr];
    Byte *userIDByte = (Byte *)[uidData bytes];
    [TTWifiUtils arrayCopyWithSrc:userIDByte srcPos:0 dst:UID dstPos:0 length:4];
    
    //密码 32byte
    Byte password[32]= {0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0};
    NSString *md5ps = [TTWIfiMD5 md5:self.userPwd];
    
    NSData *md5psData = [md5ps dataUsingEncoding:NSUTF8StringEncoding];
    Byte *md5psByte = (Byte *)[md5psData bytes];
    [TTWifiUtils arrayCopyWithSrc:md5psByte srcPos:0 dst:password dstPos:0 length:32];
    
    
    /************************公司和分店在c版没什么用 在这里充当占位符************************/
    Byte company[4]= {0x0,0x0,0x0,0x0};
    //4byte
    NSString *companyHexStr = [NSString stringWithFormat:@"%08llx",self.companyId];
    NSData *companyData = [TTWifiUtils DataFromHexStr:companyHexStr];
    Byte *companyIDByte = (Byte *)[companyData bytes];
    [TTWifiUtils arrayCopyWithSrc:companyIDByte srcPos:0 dst:company dstPos:0 length:4];
    
    
    Byte branch[4]= {0x0,0x0,0x0,0x0};
    //4byte
    
    NSString *branchHexStr = [NSString stringWithFormat:@"%08llx",self.branchId];
    NSData *branchData = [TTWifiUtils DataFromHexStr:branchHexStr];
    Byte *branchIDByte = (Byte *)[branchData bytes];
    [TTWifiUtils arrayCopyWithSrc:branchIDByte srcPos:0 dst:branch dstPos:0 length:4];
    
    /************************公司和分店在c版没什么用 在这里充当占位符************************/
    
    
    int nameLength = 51;
    Byte name[51] = {0x0};
    NSString *nameStr = [NSString stringWithFormat:@"%@\n",_plugName.length > 0 ? _plugName: _wifiMac];
    NSData *nameData = [nameStr dataUsingEncoding:NSUTF8StringEncoding];
    Byte *nameByte = (Byte *)[nameData bytes];
    [TTWifiUtils arrayCopyWithSrc:nameByte srcPos:0 dst:name dstPos:0 length:nameLength];
    
    
    NSString *IP_PORT = _debugMode.boolValue ?  @"IP:9999,120.26.119.23\r" : (_ishoneywell.boolValue ?  @"IP:9999,47.89.184.209\r": @"IP:9999,plug.sciener.cn\r");
    [sock writeData:[IP_PORT dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
    [sock writeData:[NSData dataWithBytes:UID length:4] withTimeout:-1 tag:2];
    [sock writeData:[NSData dataWithBytes:password length:32] withTimeout:-1 tag:3];
    [sock writeData:[NSData dataWithBytes:company length:4] withTimeout:-1 tag:4];
    [sock writeData:[NSData dataWithBytes:branch length:4] withTimeout:-1 tag:5];
    [sock writeData:[NSData dataWithBytes:name length:nameLength] withTimeout:-1 tag:6];
}

#pragma mark 断开连接
-(void)socketDidDisconnect:(TTWifiGCDAsyncSocket *)sock withError:(NSError *)err{
    if (self.isSuccess != 2) {
        if (self.FailBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.FailBlock();
            });
        }
    }
    
}
#pragma mark 数据发送成功
-(void)socket:(TTWifiGCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    //发送完数据手动读取，-1不设置超时
    [sock readDataWithTimeout:-1 tag:tag];
}
#pragma mark 读取数据
-(void)socket:(TTWifiGCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *receiverStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([receiverStr containsString:@"SUCCESS"]) {
        self.isSuccess = 2;
        if (self.SuccessBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.SuccessBlock(self.wifiIp,self.wifiMac);
            });
        }
    }
}

@end

