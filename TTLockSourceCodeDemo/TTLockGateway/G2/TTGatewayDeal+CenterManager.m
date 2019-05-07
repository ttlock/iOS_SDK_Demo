//
//  TTGatewayDeal+CenterManager.m
//  TTLockSourceCodeDemo
//
//  Created by 王娟娟 on 2019/4/28.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "TTGatewayDeal+CenterManager.h"
#import "TTDebugLog.h"
#import "TTDataTransformUtil.h"
#import "TTCommandUtils.h"
#import "TTGatewayCommandUtils.h"
#import "TTGatewayDeal+HandleResponse.h"

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
@implementation TTGatewayDeal (CenterManager)

-(void)createCentralManager
{
    self.bleScanDict = [NSMutableDictionary dictionary];
    self.currentLockMac = [NSString string];
    self.toConnectLockMac = [NSString string];
    //    dispatch_queue_t centralQueue = dispatch_queue_create("cn.sciener.scienerble", DISPATCH_QUEUE_SERIAL);// or however you want to create your
    //设置系统的弹框是否显示
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],CBCentralManagerOptionShowPowerAlertKey, nil];
    self.manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:options];
    
}
- (void)startScanLock{
    
    [self scanWithServicesUUIDArr:[NSArray arrayWithObject:[CBUUID UUIDWithString:gatewayServiceString]] isScanDuplicates:YES];
}


- (void)scanWithServicesUUIDArr:(NSArray*)servicesUUIDArr isScanDuplicates:(BOOL)isScanDuplicates{
    
    if ([self.manager state] != CBCentralManagerStatePoweredOn) {
        
        printf("TTLockLog#####scan，CoreBluetooth is not correctly initialized !#####");
        
        return;
    }
    [TTDebugLog log:@"TTLockLog#####Start searching for Bluetooth nearby#####"  ];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber  numberWithBool:isScanDuplicates], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    
    [self.manager scanForPeripheralsWithServices:servicesUUIDArr options:options];
    
    
}
/**停止扫描附近的蓝牙
 */
-(void)stopScanLock
{
    [TTDebugLog log:@"TTLockLog#####stop scan#####"  ];
    
    [self.manager stopScan];
    
    
}
-(void)disconnect:(CBPeripheral *)peripheral
{
    //    解决 Invalid parameter not satisfying: peripheral != nil
    if (peripheral) {
        [self.manager cancelPeripheralConnection:peripheral];
    }
    
}

- (void)connectPeripheralWithLockMac:(NSString *)lockMac{
    self.currentLockMac = lockMac;
    self.toConnectLockMac = lockMac;
    [self performSelector:@selector(connectTimeOut) withObject:nil afterDelay:TTDEFAULT_CONNECT_TIMEOUT];
    if ([self.bleScanDict objectForKey:self.toConnectLockMac]) {
        [self connect:[self.bleScanDict objectForKey:self.toConnectLockMac]];
        self.toConnectLockMac = nil;
    }
    
}
- (void)connectTimeOut{
    [TTDebugLog log:@"connectTimeOut"];
    //主动断开
    self.toConnectLockMac = nil;
    [self cancelConnectPeripheralWithLockMac:self.currentLockMac];
    self.currentLockMac = nil ;
    
    TTGatewayConnectBlock connectBlock = self.bleBlockDict[KKGATEWAYBLE_CONNECT];
    if (connectBlock)connectBlock(TTGatewayConnectTimeout);

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
            [self.manager connectPeripheral:peripheral options:nil];
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
    if ([self.bleScanDict objectForKey:lockMac]) {
        [self disconnect:[self.bleScanDict objectForKey:lockMac]];
    }
    
}


#pragma mark - CBCentralManager Delegates
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [TTDebugLog log:@"TTLockLog#####The central manager whose state has change#####"  ];
//    [delegate TTManagerDidUpdateState:(TTManagerState)central.state];
    
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
    
    NSString *m_mac = @"";
    BOOL  isDfuMode = NO;
    
    NSData * strProtocol = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    NSString *serviceUUID = [advertisementData[@"kCBAdvDataServiceUUIDs"] count] > 0 ? [[advertisementData[@"kCBAdvDataServiceUUIDs"] firstObject] UUIDString]:@"";
    if ( [serviceUUID isEqualToString:gatewayServiceString]) {
        //计算mac地址
        Byte macBytes[6];
        [TTDataTransformUtil arrayCopyWithSrc:(Byte *)strProtocol.bytes srcPos:2 dst:macBytes dstPos:0 length:6];
        NSMutableString * macBuffer = [[NSMutableString alloc]init];
        
        for (int i = 5; i >= 0 ; i --) {
            
            [macBuffer appendFormat:@"%02x:",macBytes[i]];
            
        }
        if (macBuffer.length>0) {
            
            [macBuffer deleteCharactersInRange:NSMakeRange(macBuffer.length-1, 1)];
            m_mac = [macBuffer uppercaseString];
        }
        Byte serviceBytes[2];
        [TTDataTransformUtil arrayCopyWithSrc:(Byte *)strProtocol.bytes srcPos:0 dst:serviceBytes dstPos:0 length:2];
        if (serviceBytes[0] == 0x12 && serviceBytes[1] == 0x19) {
            isDfuMode = YES;
        }

        TTGatewayScanBlock scanBlock = self.bleBlockDict[KKGATEWAYBLE_SCAN];
        if (scanBlock){
                TTGatewayScanModel *gatewayModel = [TTGatewayScanModel new];
                gatewayModel.gatewayMac = m_mac;
                gatewayModel.gatewayName = name;
                gatewayModel.isDfuMode = isDfuMode;
                gatewayModel.peripheral = peripheral;
                gatewayModel.RSSI = RSSI.integerValue;
                scanBlock(gatewayModel);
         
        }
  
    }
    if (m_mac.length > 0) {
        [self.bleScanDict setObject:peripheral forKey:m_mac];
    }else if (name.length >0){
        [self.bleScanDict setObject:peripheral forKey:name];
    }
    //是否有需要连接
    if (self.toConnectLockMac.length > 0) {
        if ([self.bleScanDict objectForKey:self.toConnectLockMac]) {
            [self connect:[self.bleScanDict objectForKey:self.toConnectLockMac]];
            self.toConnectLockMac = nil;
        };
    }
}


-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
    [TTDebugLog log:@"TTLockLog#####didConnectPeripheral#####"  ];
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
    self.isConnected = NO;
    [self removeBlock:nil untilExecute:YES];
}
- (void)removeBlock:(id)info untilExecute:(BOOL)execute{
    
    NSMutableDictionary *bleBlockDict = [self.bleBlockDict copy];
    [self.bleBlockDict removeAllObjects];
    
    [bleBlockDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isEqualToString:KKGATEWAYBLE_CONNECT])
        {
            TTGatewayConnectBlock connectBlock = bleBlockDict[key];
        
            if (connectBlock && execute)connectBlock(TTGatewayDisconnect);
         
        }else if ([key isEqualToString:KKGATEWAYBLE_SCAN])
        {
            
        }else if ([key isEqualToString:KKGATEWAYBLE_DISCONNECT])
        {
            TTGatewayBlock disconnectBlock = bleBlockDict[key];
            if (disconnectBlock && execute)disconnectBlock(TTGatewayDisconnect);
            
        }else if ([key isEqualToString:KKGATEWAYBLE_GET_SSID])
        {
            TTGatewayScanWiFiBlock ssidBlock = bleBlockDict[key];
            if (ssidBlock && execute)ssidBlock(0,nil,TTGatewayDisconnect);
            
        }else if ([key isEqualToString:KKGATEWAYBLE_CONFIG_GATEWAY]){
            TTInitializeGatewayBlock gatewayBlock = bleBlockDict[key];
            if (gatewayBlock && execute)gatewayBlock(nil,TTGatewayDisconnect);
        }
        else
        {
            TTGatewayBlock gatewayBlock = bleBlockDict[key];
            if (gatewayBlock && execute)gatewayBlock(TTGatewayDisconnect);
            
        }
    }];
}
/** Call this when things either go wrong, or you're done with the connection.
 *  This cancels any subscriptions if there are any, or straight disconnects if not.
 *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */
- (void)cleanup
{
    self.currentLockMac = nil;
    self.toConnectLockMac = nil;
    [self.manager cancelPeripheralConnection:self.activePeripheral];
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
        
        if ([TTDataTransformUtil isString:[NSString stringWithFormat:@"%s",[TTCommandUtils CBUUIDToString:service.UUID]] contain:GatewayDeviceInformation]) {
            self.gatewayDeviceInfoDic = [[NSMutableDictionary alloc]init];
            for(int i=0; i < service.characteristics.count; i++) {
                [peripheral readValueForCharacteristic:service.characteristics[i]];
                
            }
            return;
        }
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
            self.isConnected = YES;
            self.activePeripheral = peripheral;
            [self.bleBlockDict removeObjectForKey:KKGATEWAYBLE_SCAN];
            [TTGatewayCommandUtils gatewayEchoWithLockMac:self.currentLockMac];

        }else {
            // Notification has stopped
            // so disconnect from the peripheral
            [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog#####Notification stopped on %@.  Disconnecting#####", characteristic]  ];
            [self.manager cancelPeripheralConnection:peripheral];
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
    
    if ([characteristic.UUID.UUIDString isEqualToString: @"2A24"]) {
        self.gatewayDeviceInfoDic[@"modelNum"] = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        
    }
    if ([characteristic.UUID.UUIDString isEqualToString: @"2A27"]) {
        self.gatewayDeviceInfoDic[@"hardwareRevision"] = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    }
    if ([characteristic.UUID.UUIDString isEqualToString: @"2A26"]) {
        self.gatewayDeviceInfoDic[@"firmwareRevision"] = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    }
    
    //网关
    if ( [characteristic.UUID.UUIDString isEqualToString: gatewaySubReadString]) {
        [[TTGatewayDeal shareInstance] responseData:characteristic.value];
        return;
    }
    
}

@end
