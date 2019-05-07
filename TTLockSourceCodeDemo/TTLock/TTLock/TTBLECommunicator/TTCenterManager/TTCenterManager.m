//
//  TTCenterManager.m
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/4/12.
//  Copyright © 2019 wjj. All rights reserved.
//

#import "TTCenterManager.h"
#import "TTDebugLog.h"
#import "TTGatewayDeal.h"
#import "TTHandleResponse.h"
#import "TTCenterManager+ParkV2.h"
#import "TTCenterManager+Common.h"
#import "TTCenterManager+LOCKV2.h"
#import "TTCenterManager+SceneV2.h"
#import "TTHandleResponse.h"
#import "TTCenterManager+V3.h"
#import "TTDataTransformUtil.h"

/**默认蓝牙连接超时的时间*/
#define TTDEFAULT_CONNECT_TIMEOUT  10
#define fileServiceString         @"1910"
#define fileSubWriteString        @"fff2"
#define fileSubReadString         @"fff4"
#define fileService               0x1910
#define fileSubRead               0xfff4
#define bongFileServiceString     @"6e400001"//6e400001 b5a3f393 e0a9e50e 24dcca1e
#define bongFileSubWriteString    @"6e400002"
#define bongFileSubReadString     @"6e400003"
#define bongFlag                  0x3412
#define gatewayServiceString        @"1911"
#define gatewayUpgradeServiceString      @"1219"
#define gatewaySubReadString         @"0003"
#define gatewayNotifyString        @"00000003-0000-1000-8000-00805f9b34fb"
#define GatewayDeviceInformation          @"180a"

@interface TTCenterManager ()<CBPeripheralDelegate,CBCentralManagerDelegate>

@property (nonatomic,strong) NSMutableDictionary *bleScanDict;
@property (nonatomic,strong) NSString  *currentLockMac;//当前操作的
@property (nonatomic,strong) NSString  *toConnectLockMac;//需要去连接的

@end

@implementation TTCenterManager

@synthesize delegate;

static TTCenterManager *ttCenterManager;

+ (TTCenterManager*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ttCenterManager = [[TTCenterManager alloc] init];
        [ttCenterManager createCentralManager];
    });
    return ttCenterManager;
}

-(void)createCentralManager
{
    _bleScanDict = [NSMutableDictionary dictionary];
    _currentLockMac = [NSString string];
    _toConnectLockMac = [NSString string];
    [TTDebugLog log:@"TTLockLog#####Activating bluetooth#####"];
    //    dispatch_queue_t centralQueue = dispatch_queue_create("cn.sciener.scienerble", DISPATCH_QUEUE_SERIAL);// or however you want to create your
   BOOL isShowBleAlert =  [[TTLockApi sharedInstance] isShowBleAlert];
    //设置系统的弹框是否显示
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isShowBleAlert],CBCentralManagerOptionShowPowerAlertKey, nil];
    _manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:options];
    
}
- (void)startScanLock:(BOOL)isScanDuplicates{
    
    [self scanWithServicesUUIDArr:[NSArray arrayWithObject:[CBUUID UUIDWithString:fileServiceString]] isScanDuplicates:isScanDuplicates];
}
- (void)scanAllBluetoothDeviceNearby:(BOOL)isScanDuplicates{
    
    [self scanWithServicesUUIDArr:nil isScanDuplicates:isScanDuplicates] ;
    
}
- (void)scanSpecificServicesBluetoothDeviceWithServicesArray:(NSArray *)servicesArray isScanDuplicates:(BOOL)isScanDuplicates{

    NSMutableArray *servicesUUIDArr = [NSMutableArray array];
    for (NSString *str in servicesArray) {
        [servicesUUIDArr addObject:[CBUUID UUIDWithString:str]];
    }
    [self scanWithServicesUUIDArr:servicesUUIDArr isScanDuplicates:isScanDuplicates];
}

- (void)scanWithServicesUUIDArr:(NSArray*)servicesUUIDArr isScanDuplicates:(BOOL)isScanDuplicates{
    
    if ([_manager state] != CBCentralManagerStatePoweredOn) {
        
        printf("TTLockLog#####scan，CoreBluetooth is not correctly initialized !#####");
        
        return;
    }
    [TTDebugLog log:@"TTLockLog#####Start searching for Bluetooth nearby#####"  ];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber  numberWithBool:isScanDuplicates], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    
    [_manager scanForPeripheralsWithServices:servicesUUIDArr options:options];

    
}
/**停止扫描附近的蓝牙
 */
-(void)stopScanLock
{
    [TTDebugLog log:@"TTLockLog#####stop scan#####"  ];
    
    [_manager stopScan];
    
 
}
-(void)disconnect:(CBPeripheral *)peripheral
{
    //    解决 Invalid parameter not satisfying: peripheral != nil
    if (peripheral) {
        [_manager cancelPeripheralConnection:peripheral];
    }
    
}

- (void)connectPeripheralWithLockMac:(NSString *)lockMac{
    self.currentLockMac = lockMac;
    self.toConnectLockMac = lockMac;
    [self performSelector:@selector(connectTimeOut) withObject:nil afterDelay:TTDEFAULT_CONNECT_TIMEOUT];
    if ([_bleScanDict objectForKey:self.toConnectLockMac]) {
        [self connect:[_bleScanDict objectForKey:self.toConnectLockMac]];
         self.toConnectLockMac = nil;
    }
    
}
- (void)connectTimeOut{
    [TTDebugLog log:@"connectTimeOut"];
    //主动断开
    self.toConnectLockMac = nil;
    [self cancelConnectPeripheralWithLockMac:self.currentLockMac];
    self.currentLockMac = nil ;
    if ([delegate respondsToSelector:@selector(TTError:command:errorMsg:)]) {
        [delegate TTError:TTErrorConnectionTimeout command:TTErrorConnectionTimeout errorMsg:TTErrorMessageConnectionTimeout];
    }
}
- (void)cancelConnectTimeOut{
    
    [NSRunLoop cancelPreviousPerformRequestsWithTarget:self
                                              selector:@selector(connectTimeOut)
                                                object:nil];
}

/**连接蓝牙
 */
-(void) connect:(CBPeripheral *)peripheral
{
    //    解决 Invalid parameter not satisfying: peripheral != nil
    if (peripheral) {
        if (peripheral.state != CBPeripheralStateConnected) {
            [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog#####connect:%@#####",peripheral]  ];
            [_manager connectPeripheral:peripheral options:nil];
        }
    }
}

/**断开蓝牙连接
 */
- (void)cancelConnectPeripheralWithLockMac:(NSString *)lockMac{
    if (lockMac.length == 0) {
        return;
    }
    if ([lockMac isEqualToString:self.currentLockMac]) {
        [self cancelConnectTimeOut];
        self.currentLockMac = nil;
        self.toConnectLockMac = nil;
        
    }
    //把所有要连接这个锁的都取消
    if ([_bleScanDict objectForKey:lockMac]) {
        [self disconnect:[_bleScanDict objectForKey:lockMac]];
    }
    
}


#pragma mark - CBCentralManager Delegates
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [TTDebugLog log:@"TTLockLog#####The central manager whose state has change#####"  ];
    [delegate TTBluetoothDidUpdateState:(TTBluetoothState)central.state];
    
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //广播包不一定能都搜到，所以名字kCBAdvDataLocalName可能会没有
    if(advertisementData == nil){
        return;
    }
    NSString* localName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    NSString* name = localName.length > 0 ? localName : peripheral.name ;
    //这款蓝牙模块存在的问题之一，只有经过第一次连接成功之后，所获取到的数据才正常。
    if(peripheral.identifier == NULL) {
        [central connectPeripheral:peripheral options:nil];
        return;
    }
    if (!peripheral) return;

    BOOL  isInited = NO ;
    NSString *m_mac = @"";
    BOOL  isDfuMode = NO;
    
    NSData * strProtocol = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    NSString *serviceUUID = [advertisementData[@"kCBAdvDataServiceUUIDs"] count] > 0 ? [[advertisementData[@"kCBAdvDataServiceUUIDs"] firstObject] UUIDString]:@"";
    
    int protocolCategory  = 0;
    int protocolVersion  = 0;
    int applyCatagory = 0;
    int applyID = 0;
    int applyID2 = 0;
    int  electricQuantity = -1;
    TTLockSwitchState lockSwitchState  = TTLockSwitchStateUnknown;
    BOOL allowUnlock = NO;
    int oneMeterRSSI = 0;
    BOOL doorSensorState = NO;
    
    if (strProtocol == nil) {
        //电池电量
        electricQuantity = -1;
        m_mac = @"";
        protocolCategory = 5;
        protocolVersion = 1;
        applyCatagory = 1;
        applyID = 1;
        applyID2 = 1;
        allowUnlock = 1;
        oneMeterRSSI = RSSI_SETTING_1m;
        lockSwitchState = TTLockSwitchStateUnknown;
    }else{
        
        Byte * bytes = (Byte *)strProtocol.bytes;
        //bong手环
        if ([TTDataTransformUtil intFromHexBytes:&bytes[0] length:1] == 0x34 && [TTDataTransformUtil intFromHexBytes:&bytes[1] length:1] == 0x12) {
            lockSwitchState = TTLockSwitchStateUnknown;
            isInited = NO;
            protocolCategory = bongFlag;
            //计算mac地址
            Byte macBytes[6];
            [TTDataTransformUtil arrayCopyWithSrc:bytes srcPos:2 dst:macBytes dstPos:0 length:6];
            NSMutableString * macBuffer = [[NSMutableString alloc]init];
            
            for (int i = 5; i >= 0 ; i --) {
                [macBuffer appendFormat:@"%02x:",macBytes[i]];
            }
            if (macBuffer.length>0) {
                [macBuffer deleteCharactersInRange:NSMakeRange(macBuffer.length-1, 1)];
                m_mac = [macBuffer uppercaseString];
            }
            
        }else if(strProtocol.length == 18){
            //协议版本：4
            //协议类别：5
            //应用类别：6~7
            //所状态，有无管理员:8
            //电池电压：9
            //mac:12~17
            
            //计算mac地址
            Byte macBytes[6];
            [TTDataTransformUtil arrayCopyWithSrc:bytes srcPos:12 dst:macBytes dstPos:0 length:6];
            NSMutableString * macBuffer = [[NSMutableString alloc]init];
            
            for (int i = 5; i >= 0 ; i --) {
                [macBuffer appendFormat:@"%02x:",macBytes[i]];
            }
            if (macBuffer.length>0) {
                [macBuffer deleteCharactersInRange:NSMakeRange(macBuffer.length-1, 1)];
                m_mac = [macBuffer uppercaseString];
            }
            //版本信息
            Byte pType[1];
            Byte pVersion[1];
            Byte pScene[2];
            Byte pGroupid[2];
            Byte pOrgid[2];
            
            pType[0] = bytes[4];
            pVersion[0] = bytes[5];
            pScene[0] = bytes[6];
            //pScene[0] = 0;
            pScene[1] = bytes[7];
            pOrgid[0] = 0;
            pOrgid[1] = 1;
            pGroupid[0] = 0;
            pGroupid[1] = 1;
            
            protocolCategory = [TTDataTransformUtil intFromHexBytes:pType length:1];
            protocolVersion = [TTDataTransformUtil intFromHexBytes:pVersion length:1];
            applyCatagory = [TTDataTransformUtil intFromHexBytes:pScene length:2];
            applyID = [TTDataTransformUtil intFromHexBytes:pOrgid length:2];
            applyID2 = [TTDataTransformUtil intFromHexBytes:pGroupid length:2];
            
            lockSwitchState = TTLockSwitchStateUnknown;
            allowUnlock = 1;
            oneMeterRSSI = RSSI_SETTING_1m;
            
            if ((bytes[8]&0x04) != 0) {
                //1没有
                isInited = NO;
                
            }else{
                //2有
                isInited = YES;
                
            }
            //电池电量
            electricQuantity = -1;
            
        }
        else if (strProtocol.length == 17){
            //三代锁
            //
            Byte pType[1];
            Byte pVersion[1];
            Byte pScene[1];
            Byte pGroupid[1];
            Byte pOrgid[1];
            
            pType[0] = bytes[0];
            pVersion[0] = bytes[1];
            pScene[0] = bytes[2];
            pOrgid[0] = 1;
            //            pOrgid[1] = 0;
            pGroupid[0] = 1;
            //            pGroupid[1] = 0;
            
            protocolCategory = [TTDataTransformUtil intFromHexBytes:pType length:1];
            protocolVersion = [TTDataTransformUtil intFromHexBytes:pVersion length:1];
            applyCatagory = [TTDataTransformUtil intFromHexBytes:pScene length:1];
            applyID = [TTDataTransformUtil intFromHexBytes:pOrgid length:1];
            applyID2 = [TTDataTransformUtil intFromHexBytes:pGroupid length:1];
            
            lockSwitchState = TTLockSwitchStateUnknown;
            if (applyCatagory == ParkSceneType) {
                //            第 0 位：锁的开关状态
                //            与第4位组合识别
                //            第4位    第0位
                //            0    0    闭锁
                //            0    1    开锁，无车
                //            1    0    状态未知
                //            1    1    开锁，有车
                BOOL lockStateZero = bytes[3]&0x01;
                BOOL lockStateFour = bytes[3]&16;
                if (lockStateZero == 0 && lockStateFour == 0) {
                    lockSwitchState = TTLockSwitchStateLock;
                }
                if (lockStateZero == 0 && lockStateFour == 1) {
                    lockSwitchState = TTLockSwitchStateUnlock;
                }
                if (lockStateZero == 1 && lockStateFour == 0) {
                    lockSwitchState = TTLockSwitchStateUnknown;
                }
                if (lockStateZero == 1 && lockStateFour == 1) {
                    lockSwitchState = TTLockSwitchStateUnlockHasCar;
                }
            }
            //第四个字节 第5位 门磁状态
            doorSensorState = bytes[3]&32;
            allowUnlock = bytes[3]&0x08 ;
            if ((bytes[3]&0x04) != 0) {
                //1没有
                isInited = NO;
            }else{
                //2有
                isInited = YES;
            }
            //电池电量
            electricQuantity = bytes[4];
            //计算mac地址
            Byte macBytes[6];
            [TTDataTransformUtil arrayCopyWithSrc:bytes srcPos:11 dst:macBytes dstPos:0 length:6];
            NSMutableString * macBuffer = [[NSMutableString alloc]init];
            for (int i = 5; i >= 0 ; i --) {
                
                [macBuffer appendFormat:@"%02x:",macBytes[i]];
                
            }
            if (macBuffer.length>0) {
                
                [macBuffer deleteCharactersInRange:NSMakeRange(macBuffer.length-1, 1)];
                m_mac = [macBuffer uppercaseString];
            }
            oneMeterRSSI =  [[advertisementData objectForKey:@"kCBAdvDataTxPowerLevel"] intValue];
            
        }else if (strProtocol.length == 8){
            //电池电量
            electricQuantity = -1;
            protocolCategory = 5;
            protocolVersion = 3;
            applyCatagory = 0;
            applyID = 0;
            applyID2 = 0;
            allowUnlock = 0;
            oneMeterRSSI = RSSI_SETTING_1m;
            lockSwitchState = TTLockSwitchStateUnknown;
            int specialMark =  [TTDataTransformUtil intFromHexBytes:&bytes[0] length:1];
            int specialMark2 = [TTDataTransformUtil intFromHexBytes:&bytes[1] length:1];
            if (specialMark == 0xff && specialMark2 == 0xff) {
                isDfuMode = YES;
            }
            //计算mac地址
            Byte macBytes[6];
            [TTDataTransformUtil arrayCopyWithSrc:bytes srcPos:2 dst:macBytes dstPos:0 length:6];
            NSMutableString * macBuffer = [[NSMutableString alloc]init];
            
            for (int i = 5; i >= 0 ; i --) {
                [macBuffer appendFormat:@"%02x:",macBytes[i]];
            }
            if (macBuffer.length>0) {
                [macBuffer deleteCharactersInRange:NSMakeRange(macBuffer.length-1, 1)];
                m_mac = [macBuffer uppercaseString];
            }
        }else{
             //不符合长度的 不管
            return;
        }
        
    }
    
    if (m_mac.length > 0) {
        [_bleScanDict setObject:peripheral forKey:m_mac];
    }else if (name.length >0){
        [_bleScanDict setObject:peripheral forKey:name];
    }
    //是否有需要连接
    if (self.toConnectLockMac.length > 0) {
        if ([_bleScanDict objectForKey:self.toConnectLockMac]) {
            [self connect:[_bleScanDict objectForKey:self.toConnectLockMac]];
            self.toConnectLockMac = nil;
        };
    }
  
    if ([delegate respondsToSelector:@selector(onScanLockWithModel:)]) {
        NSMutableDictionary *infoDic = [[NSMutableDictionary alloc]init];
        [infoDic setObject:NOTNILSTRING(RSSI) forKey:@"RSSI"];
        [infoDic setObject:NOTNILSTRING(peripheral) forKey:@"peripheral"];
        [infoDic setObject:NOTNILSTRING(name) forKey:@"lockName"];
        [infoDic setObject:NOTNILSTRING(m_mac) forKey:@"lockMac"];
        [infoDic setObject:@(isInited) forKey:@"isInited"];
        [infoDic setObject:@(allowUnlock) forKey:@"isAllowUnlock"];
        [infoDic setObject:@(oneMeterRSSI) forKey:@"oneMeterRSSI"];
        [infoDic setObject:@(lockSwitchState) forKey:@"lockSwitchState"];
        [infoDic setObject:@(doorSensorState) forKey:@"doorSensorState"];
        [infoDic setObject:@(electricQuantity) forKey:@"electricQuantity"];
        infoDic[@"isDfuMode"] = @(isDfuMode);
        NSMutableDictionary *lockVersionDic = [NSMutableDictionary new];
        lockVersionDic[@"protocolType"] = @(protocolCategory);
        lockVersionDic[@"protocolVersion"] = @(protocolVersion);
        lockVersionDic[@"scene"] = @(applyCatagory);
        lockVersionDic[@"groupId"] = @0;
        lockVersionDic[@"orgId"] = @0;
        NSString *lockVersion = [TTDataTransformUtil convertToJsonData:lockVersionDic];
        infoDic[@"lockVersion"] = lockVersion;
        TTScanModel *model = [[TTScanModel alloc]initWithInfoDic:infoDic];
        [delegate onScanLockWithModel:model];
        
    }
}


-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
    [TTDebugLog log:@"TTLockLog#####didConnectPeripheral#####"  ];
    _activePeripheral = peripheral;
    peripheral.delegate = self;
    [self cancelConnectTimeOut];
    if ((peripheral.state == CBPeripheralStateConnected)) {
        
        [peripheral discoverServices:@[]];//[CBUUID UUIDWithString:fileServiceString],[CBUUID UUIDWithString:bongFileServiceString]
    }
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog#####did Disconnect, error %@#####",error]];
    [self cancelConnectTimeOut];
    self.currentLockMac = nil;
    self.toConnectLockMac = nil;
    self.activePeripheral = nil;
    self.lockDataModel =  nil;
    self.m_startDate = nil;
    self.m_endDate = nil;
   self.m_keyboard_delete_admin = nil;
   self.m_keyboard_password_admin = nil;
    self.passwordFromLock = 0;
    //操作记录
    if (_lockOpenRecordArr.count > 0) {
        [self onGetOperateLog:NO];
    }else{
        _lockOpenRecordArr = nil;
    }
    
    if ([delegate respondsToSelector:@selector(onBTDisconnectWithPeripheral:)]) {
        [delegate onBTDisconnectWithPeripheral:peripheral];
    }
    
}

/** Call this when things either go wrong, or you're done with the connection.
 *  This cancels any subscriptions if there are any, or straight disconnects if not.
 *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */
- (void)cleanup
{
    self.currentLockMac = nil;
    self.toConnectLockMac = nil;
     [_manager cancelPeripheralConnection:_activePeripheral];
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
    [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog#####failed to connect to peripheral %@: %@\n#####",[peripheral name], [error localizedDescription]]  ];
    [self cleanup];
}
#pragma mark - CBPeripheral delegates

//解决 [CoreBluetooth] API MISUSE: Reading RSSI for peripheral <CBPeripheral: 0x1c03037b0, identifier = C270DD91-9B75-FC4D-23EB-5B9D08658288, name = J301_cd38b5, state = connected> while delegate is either nil or does not implement peripheral:didReadRSSI:error:
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog#####didWriteValueForCharacteristic,Write Value uuid:%@#####",characteristic.UUID]  ];
    
    /* When a write occurs, need to set off a re-read of the local CBCharacteristic to update its value */
    if (error) {
        [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog#####did Write fail %@: %@#####",[peripheral name], [error localizedDescription]]  ];
    }else{
        if ([TTDataTransformUtil isString:[NSString stringWithFormat:@"%s",[TTCommandUtils CBUUIDToString:characteristic.UUID]] contain:fileSubReadString]
            || [TTDataTransformUtil isString:[NSString stringWithFormat:@"%s",[TTCommandUtils CBUUIDToString:characteristic.UUID]] contain:bongFileSubReadString]
            || [TTDataTransformUtil isString:[NSString stringWithFormat:@"%s",[TTCommandUtils CBUUIDToString:characteristic.UUID]] contain:gatewayNotifyString]) {
            
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    
    [TTDebugLog log:@"TTLockLog#####didWriteValueForDescriptor#####"  ];
    
}


/*  @method didDiscoverServices */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        [peripheral readRSSI];
        if (peripheral.services.count == 0) {
            [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog#####not found %@ services#####",peripheral.name] ];
            return;
        }
        
         [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog#####Services of peripheral with UUID : %s found#####",[TTCommandUtils UUIDToString:(__bridge CFUUIDRef)peripheral.identifier]]  ];
        
        for (int i=0; i < peripheral.services.count; i++) {
            CBService *s = [peripheral.services objectAtIndex:i];
          
            if ([TTDataTransformUtil isString:[NSString stringWithFormat:@"%s",[TTCommandUtils CBUUIDToString:s.UUID]] contain:fileServiceString]
                || [TTDataTransformUtil isString:[NSString stringWithFormat:@"%s",[TTCommandUtils CBUUIDToString:s.UUID]] contain:bongFileServiceString]
                || [TTDataTransformUtil isString:[NSString stringWithFormat:@"%s",[TTCommandUtils CBUUIDToString:s.UUID]] contain:gatewayServiceString]
                || [TTDataTransformUtil isString:[NSString stringWithFormat:@"%s",[TTCommandUtils CBUUIDToString:s.UUID]] contain:GatewayDeviceInformation]) {
                [TTDebugLog log:@"TTLockLog#####search characteristics#####"  ];
                
                [peripheral discoverCharacteristics:nil forService:s];
                
            }
        }
       

    } else {
        
        [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog#####didDiscoverServices,error:%@#####",[error localizedDescription]]  ];
        [self cleanup];
        return;
    }
}

/*  @method didDiscoverCharacteristicsForService */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog#####Characteristics of service with UUID : %s found#####",[TTCommandUtils CBUUIDToString:service.UUID]]  ];
        
        for(int i=0; i < service.characteristics.count; i++) {
            CBCharacteristic *c = [service.characteristics objectAtIndex:i];
            if ([TTDataTransformUtil isString:[NSString stringWithFormat:@"%s",[TTCommandUtils CBUUIDToString:c.UUID]] contain:fileSubReadString]
                || [TTDataTransformUtil isString:[NSString stringWithFormat:@"%s",[TTCommandUtils CBUUIDToString:c.UUID]] contain:bongFileSubReadString]
                || [TTDataTransformUtil isString:[NSString stringWithFormat:@"%s",[TTCommandUtils CBUUIDToString:c.UUID]] contain:gatewaySubReadString]) {
                
                [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog#####Found characteristic %s#####",[ TTCommandUtils CBUUIDToString:c.UUID]]  ];
                
                [peripheral setNotifyValue:YES forCharacteristic:c];
                return;
            }
            
        }
    }
    else {
        [TTDebugLog log:@"Characteristic discorvery unsuccessfull !"  ];
        [self cleanup];
        return;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error) {
        [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog#####Updated notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s#####",[TTCommandUtils CBUUIDToString:characteristic.UUID],[TTCommandUtils CBUUIDToString:characteristic.service.UUID],[TTCommandUtils UUIDToString:(__bridge CFUUIDRef)peripheral.identifier]]  ];

        if (characteristic.isNotifying) {
            
            if ([delegate respondsToSelector:@selector(onBTConnectSuccessWithPeripheral:lockName:)]) {
                [delegate onBTConnectSuccessWithPeripheral:peripheral lockName:peripheral.name];
                 self.m_lockName = peripheral.name;
            }
        }else {
            // Notification has stopped
            // so disconnect from the peripheral
            [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog#####Notification stopped on %@.  Disconnecting#####", characteristic]  ];
            [_manager cancelPeripheralConnection:peripheral];
        }
        
    }
    else {
        [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog#####NError in setting notification state for characteristic, %@.#####", [error description]]  ];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [TTDebugLog log:@"TTLockLog#####didUpdateValueForCharacteristic#####"  ];
    
    if (error  ) {
        [TTDebugLog log:@"TTLockLog#####updateValueForCharacteristic failed#####"  ];
        return;
    }
    
  
    //如果是写给bong的 直接回调
    NSString *dataStr = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    if ([dataStr isEqualToString:@"success"]) {
        if (_bongOperateType == 1) {
            if ([delegate respondsToSelector:@selector(onSetWristbandKey)]) {
                [delegate onSetWristbandKey];
            }
        }else{
            if([delegate respondsToSelector:@selector(onSetWristbandRssi)]){
                [delegate onSetWristbandRssi];
            }
        }
        
        return;
    }
    
    [TTDebugLog log:@"TTLockLog#####Get the data#####"];
    
   TTCommand *command = [TTHandleResponse handleCommandResponse:characteristic.value] ;
    if (command) {
     
        if (self.m_currentOperatorState == Current_Operator_State_Get_Lock_Version) {
            
            //获取到lock信息
            if ([delegate respondsToSelector:@selector(onGetLockVersion:)]) {
                
                NSMutableDictionary *lockVersionDic = [NSMutableDictionary new];
                lockVersionDic[@"protocolType"] = [NSString stringWithFormat:@"%d",command->protocolCategory];
                lockVersionDic[@"protocolVersion"] = [NSString stringWithFormat:@"%d",command->protocolVersion] ;
                lockVersionDic[@"scene"] = [NSString stringWithFormat:@"%d",command->applyCatagory];
                lockVersionDic[@"groupId"] = [NSString stringWithFormat:@"%d",[TTDataTransformUtil intFromHexBytes:command->applyID length:2]];
                lockVersionDic[@"orgId"] = [NSString stringWithFormat:@"%d",[TTDataTransformUtil intFromHexBytes:command->applyID2 length:2]];
//                NSString *lockVersion = [TTDataTransformUtil convertToJsonData:lockVersionDic];
                [delegate onGetLockVersion:lockVersionDic];
            }
            self.isFirstCommand = NO;
            [TTDebugLog log:@"TTLockLog#####Get the version number successfully#####"];
            return;
            
        }
        
        if (command->protocolVersion == 0x04) {
           [self sceneV2HandleCommand:command];
        }else if (command->protocolVersion == 0x03){
             [self lockV3HandleCommand:command];
            
        }else if (command->protocolCategory == Version_Lock_v4){
            [self LOCKV2HandleCommand:command];
        }else if(command->protocolCategory == Version_PARK_Lock_v1 && command->protocolVersion == 0x01) {
            [self parkV2HandleCommand:command];
        }
    }
}

-(void)dealloc{
    
}

@end
