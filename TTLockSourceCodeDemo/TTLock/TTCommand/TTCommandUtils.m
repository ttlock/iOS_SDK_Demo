//
//  CommandUtils.m
//  BTstackCocoa
//
//  Created by wan on 13-2-22.
//
//

#import "TTCommandUtils.h"
#import "TTCenterManager.h"
#import "TTDateHelper.h"
#import "TTDataTransformUtil.h"

#define fileSubWriteString        @"fff2"
#define fileService               0x1910
#define fileSubWrite              0xfff2
#define bongFileSubWriteString    @"6e400002"
#define bongFlag                  0x3412

@implementation TTCommandUtils

BOOL DEBUG_COMMANDUTILS = NO;

extern Byte VALUE_OFF;
extern Byte VALUE_ON;


// 计算和，必须小于4294967295   5.3 5.4锁没有限制
+(NSString*) getUnlockPassword:(long long)passwordFromLock localPassword:(long long)localPassword{
    
    
//    long long result = (passwordFromLock + localPassword) % 2000000000;
    long long result = passwordFromLock + localPassword;
    return [NSString stringWithFormat:@"%lld",result];
}

//车位锁是计算和 取余
+(NSString*)getParkUnlockPassword:(long long)passwordFromLock localPassword:(long long)localPassword{
    
    //    long long result = (passwordFromLock + localPassword) % 2000000000;
    long long result = (passwordFromLock + localPassword) % 0xFFFFFFFF;
    return [NSString stringWithFormat:@"%lld",result];
}

/***********************************LOCK V4***************************************/

+(void)initialization_fetchLockDetail{
    
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[0];
    [command setCommand:COMM_INITIALIZATION];
    [command setData:values withLength:0];
    [self readyToWriteValueWithComand:command];
}
// add admin，约定数字和随机数规定小于20 00 00 00 00
+(void)v4_add_admin_with_ps:(NSString*)password
                     number:(NSString*)unlocknumber {
  
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[14]={
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00
    };
    
    Byte psByte[password.length];
    for (int i = 0 ; i < password.length; i ++) {
        
        NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",[password characterAtIndex:i]-'0']];
        
        Byte *numberByte = (Byte *)[numberData bytes];
        psByte[i] = numberByte[0];
        
    }
    
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:10-password.length length:10];
    
    //注释：
    //  14 99 02 38  hex
    //  转换之后：
    //  14 99 02 38
    
    long long  unlockNumber = unlocknumber.longLongValue;
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx",unlockNumber]];
    
    Byte *numberByte = (Byte *)[numberData bytes];
    
    
    [TTDataTransformUtil arrayCopyWithSrc:numberByte  srcPos:0 dst:values dstPos:10 length:4];
    
    
    [command setCommand:COMM_ADD_ADMIN];
    
    [command setData:values withLength:14];
    
   [self readyToWriteValueWithComand:command];
    
}

// check admin;flag：实效flag
//TODO 实效flag1个字节太短了 3个字节可以
+(void)v4_check_admin_with_ps:(NSString*)password flag:(int)flag {
    
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[13]={
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00};
    
    //    NSData *psData = [password dataUsingEncoding: NSUTF8StringEncoding];
    //    Byte *psByte = (Byte *)[psData bytes];
    
    Byte psByte[password.length];
    for (int i = 0 ; i < password.length; i ++) {
        
        NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",[password characterAtIndex:i]-'0']];
        
        Byte *numberByte = (Byte *)[numberData bytes];
        psByte[i] = numberByte[0];
        
    }
    
    
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:10-password.length length:password.length];

    
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",flag]];
    Byte *numberByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:numberByte  srcPos:0 dst:values dstPos:13-numberData.length length:numberData.length];
    
    [command setCommand:COMM_ADD_USER];
    
    
    [command setData:values withLength:13];
    
    
   [self readyToWriteValueWithComand:command];
    
}

// unlock  --flag(’0x00’,无操作;’0x01’, 设置无钥匙密码;’0x02’,校准时钟;'0x03',同步当前有效密码序列)
// psCurrent当前有效密码序列组
+(void)v4_unlock_psFromLock:(long long)psFromLock psLocal:(long long)psLocal flag:(NSString*)flag 
{
    NSString *sum = [self getUnlockPassword:psFromLock localPassword:psLocal];
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[5]={0x00,0x00,0x00,0x00,0x00};
    
    
    long long sumNumber = sum.longLongValue;
    NSData *sumData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx",sumNumber]];
    Byte *sumByte = (Byte *)[sumData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:sumByte  srcPos:0 dst:values dstPos:0 length:4];
    
    
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",flag.intValue]];
    Byte *numberByte = (Byte *)[numberData bytes];
    
    //    NSData *numberData = [flag dataUsingEncoding: NSUTF8StringEncoding];
    //    Byte *numberByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:numberByte  srcPos:0 dst:values dstPos:4 length:1];
    
    
    [command setCommand:COMM_LOCK_UNLOCK];
    
    
    [command setData:values withLength:5];
    
    
   [self readyToWriteValueWithComand:command];
    
}

// 校准时间
+(void)v4_calibation_timeWithVersion:(NSString*)version  referenceTime:(NSString*)referenceTime{
    
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[5]={0x00,0x00,0x00,0x00,0x00};
  
    NSArray * timeArray = [referenceTime componentsSeparatedByString:@"-"];
    for (int i = 0 ; i < timeArray.count ; i ++) {
        
        int number = ((NSString *)timeArray[i]).intValue;
        
        NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",number]];
        
        Byte *numberByte = (Byte *)[numberData bytes];
        values[i] = numberByte[0];
        
    }
    
    [command setCommand:COMM_LOCK_TIME_CALIBRATION];
    
    [command setData:values withLength:5];
    
   [self readyToWriteValueWithComand:command];
    
}

//设置管理员无钥匙密码
+(void)v4_set_admin_nokey_ps:(NSString*)password {

    
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[10] = {
        0xFF,0xFF,0xFF,0xFF,0xFF,
        0xFF,0xFF,0xFF,0xFF,0xFF
    };
    
    //    NSData *psData = [password dataUsingEncoding: NSUTF8StringEncoding];
    //    Byte *psByte = (Byte *)[psData bytes];
    
    Byte psByte[password.length];
    for (int i = 0 ; i < password.length; i ++) {
        
        NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",[password characterAtIndex:i]-'0']];
        
        Byte *numberByte = (Byte *)[numberData bytes];
        psByte[i] = numberByte[0];
        
    }
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:0 length:password.length];
    
    
    [command setCommand:COMM_LOCK_SET_ADMIN_PS];
    
    [command setData:values withLength:10];
    
   [self readyToWriteValueWithComand:command];
    
}
/**设置管理员删除密码：7到10位
 */
+(void)v4_set_admin_delete_ps:(NSString*)password 
{
    
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[10]={
        0xFF,0xFF,0xFF,0xFF,0xFF,
        0xFF,0xFF,0xFF,0xFF,0xFF
    };
    
    Byte psByte[password.length];
    for (int i = 0 ; i < password.length; i ++) {
        
        NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",[password characterAtIndex:i]-'0']];
        
        Byte *numberByte = (Byte *)[numberData bytes];
        psByte[i] = numberByte[0];
        
    }
    
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:0 length:password.length];
    
    [command setCommand:COMM_COMM_LOCK_SET_ADMIN_DEL_PS];
    
    [command setData:values withLength:10];
    
   [self readyToWriteValueWithComand:command];
    
}

//普通用户时效性检测
//TODO 实效flag一个字节太短了，3个字节可以
+(void)v4_check_user_startDate:(NSString*)startDate endDate:(NSString*)endDate flag:(int)flag {

    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[13]={
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00
    };
    
    // start date
    {
        
        NSArray * timeArray = [startDate componentsSeparatedByString:@"-"];
        for (int i = 0 ; i < timeArray.count ; i ++) {
            
            int unlockNumber = ((NSString *)timeArray[i]).intValue;
            
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",unlockNumber]];
            
            Byte *numberByte = (Byte *)[numberData bytes];
            values[i] = numberByte[0];
            
        }
        
    }
    
    // end date
    {
        
        NSArray * timeArray = [endDate componentsSeparatedByString:@"-"];
        for (int i = 0 ; i < timeArray.count ; i ++) {
            
            int unlockNumber = ((NSString *)timeArray[i]).intValue;
            
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",unlockNumber]];
            
            Byte *numberByte = (Byte *)[numberData bytes];
            values[5+i] = numberByte[0];
            
        }
        
    }
    
    //flag
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",flag]];
    Byte *numberByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:numberByte  srcPos:0 dst:values dstPos:13-numberData.length length:numberData.length];
    
    [command setCommand:COMM_LOCK_CHECK_USER_TIME];
    
    [command setData:values withLength:13];
    
    [self readyToWriteValueWithComand:command];
    
}

//设置删除有效密码指令  密码：7到10位
+(void)v4_set_admin_del_ps:(NSString*)password 
{
    
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[10]={
        0xFF,0xFF,0xFF,0xFF,0xFF,
        0xFF,0xFF,0xFF,0xFF,0xFF
    };
    
    //    NSData *psData = [password dataUsingEncoding: NSUTF8StringEncoding];
    //    Byte *psByte = (Byte *)[psData bytes];
    
    Byte psByte[password.length];
    for (int i = 0 ; i < password.length; i ++) {
        
        NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",[password characterAtIndex:i]-'0']];
        
        Byte *numberByte = (Byte *)[numberData bytes];
        psByte[i] = numberByte[0];
        
    }
    
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:0 length:password.length];
    
    [command setCommand:COMM_COMM_LOCK_SET_ADMIN_DEL_PS];
    
    [command setData:values withLength:10];
    
   [self readyToWriteValueWithComand:command];
    
}

/**初始化密码池，每次发送5条，每条6个字节
 */

+(void)v4_init_ps_pool:(NSArray*)passwords pos:(int)pos 
{
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[32] = {
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00};
    
    for (int i = 0 ; i < passwords.count ; i ++ ) {
        
        NSString * password = [passwords objectAtIndex:i];
        
        //        NSData *psData = [password dataUsingEncoding: NSUTF8StringEncoding];
        //        Byte *psByte = (Byte *)[psData bytes];
        
        
        Byte psByte[password.length];
        for (int i = 0 ; i < password.length; i ++) {
            
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",[password characterAtIndex:i]-'0']];
            
            Byte *numberByte = (Byte *)[numberData bytes];
            psByte[i] = numberByte[0];
            
        }
        
        
        [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:i*6 length:password.length];
        
  
    }
    
    // 密码位置：0，5...i*5...895
    NSString * hexStr = [NSString stringWithFormat:@"%02x",pos];
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:hexStr];
    Byte *numberByte = (Byte *)[numberData bytes];
    
    if (numberData.length>1) {
        
        [TTDataTransformUtil arrayCopyWithSrc:numberByte  srcPos:0 dst:values dstPos:30 length:2];
    }else{
        
        [TTDataTransformUtil arrayCopyWithSrc:numberByte  srcPos:0 dst:values dstPos:31 length:1];
    }
    
    
    [command setCommand:COMM_LOCK_INIT_PS];
    
    [command setData:values withLength:32];
    
   [self readyToWriteValueWithComand:command];
    
}

/** 同步有效密码序列.
 *  serialNumberBytes 16个字节。发送各组当前当前有效密码序列。发送顺序：1天，2天，3天，4天，5天，6天，7天，10分钟。需要严格按照这个顺序来发送。
 */
+(void)v4_update_ps_serial_number:(Byte*)serialNumberBytes 
{
    
      TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    
    [command setCommand:V4_COMM_LOCK_SERIAL_NUMBER];
    
    [command setData:serialNumberBytes withLength:16];
    
    [self readyToWriteValueWithComand:command];
    
}

+(void)v4_update_ps_serial_number:(Byte*)serialNumberBytes indexLen:(int)indexlen group:(int)group 
{
    
     Byte values[3]={
        0x00,0x00,0x00
    };
    values[0] = group;
    
    if (indexlen == 2) {
        
        [TTDataTransformUtil arrayCopyWithSrc:serialNumberBytes  srcPos:0 dst:values dstPos:1 length:2];
    }else{
        
        [TTDataTransformUtil arrayCopyWithSrc:serialNumberBytes  srcPos:0 dst:values dstPos:2 length:1];
    }
    
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    [command setCommand:V4_COMM_LOCK_SERIAL_NUMBER];
    [command setData:values withLength:3];
    
   [self readyToWriteValueWithComand:command];
    
}

+ (void)v4_initializ_password_code:(NSArray *)codeArr
                         secretKey:(NSArray *)secretKey
                           version:(NSString*)version
                              year:(NSString*)year
                               key:(Byte*)pwdkey 
{
    TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:nil];
    
    Byte values[61]={
        0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,
        0x0
    };
    
    NSData *yearData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",year.intValue - 2000]];
    Byte *yearByte = (Byte *)[yearData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:yearByte  srcPos:0 dst:values dstPos:0 length:1];
    
    long long sum;
    //后边是9个0 2个0是一个字节
    long long temp = 0x1000000000;
    
    for (int i = 0; i < 10; i++) {
        
        if ([(NSString *)codeArr[i] longLongValue] > 0xff) {
            
            sum = [(NSString *)codeArr[i] longLongValue] * temp + [(NSString *)secretKey[i] longLongValue];
            NSData *sumData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%12llx",sum]];
            Byte *sumByte = (Byte *)[sumData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:sumByte  srcPos:0 dst:values dstPos:i*6 + 1 length:6];
            
        } else if ([(NSString *)codeArr[i] longLongValue] > 0xf) {
            
            sum = [(NSString *)codeArr[i] longLongValue] * temp + [(NSString *)secretKey[i] longLongValue];
            NSData *sumData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%11llx",sum]];
            Byte *sumByte = (Byte *)[sumData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:sumByte  srcPos:0 dst:values dstPos:i*6 + 1 length:6];
            
        } else {
            
            sum = [(NSString *)codeArr[i] longLongValue] * temp + [(NSString *)secretKey[i] longLongValue];
            NSData *sumData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%10llx",sum]];
            Byte *sumByte = (Byte *)[sumData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:sumByte  srcPos:0 dst:values dstPos:i*6 + 2 length:5];
            
        }
    }
    
    [command setCommand:COMM_LOCK_INITIALIZ_PASSWORD];
    
    [command setDataAES:values withLength:61 key:pwdkey];
    
   [self readyToWriteValueWithComand:command];
    
}
+(void)v3_lock_v1_reset_version:(NSString*)version
                                     key:(Byte*)pwdkey{
    
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    Byte values[0];
    [command setCommand:COMM_LOCK_RESET];
    [command setDataAES:values withLength:0 key:pwdkey];
    [self readyToWriteValueWithComand:command];
  
}

+(void)v3_lock_v1_notify_addAdmin_success_version:(NSString*)version
                                                       key:(Byte*)pwdkey
                                       {
    
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    Byte values[0];
    [command setCommand:COMM_LOCK_NOTIFY_ADDADMIN];
    [command setDataAES:values withLength:0 key:pwdkey];
    
   [self readyToWriteValueWithComand:command];
    
}
+ (void)v3_getLockSwitchState{
   
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[0];
    [command setCommand:Lock_V3_COMM_SWITCH_STATE];
    [command setData:values withLength:0];
    [self readyToWriteValueWithComand:command];

}

+(void)v3_fetchLockAesKeyWithSetClientPara:(NSString*)setClientPara
                          version:(NSString*)version
                                          key:(Byte*)pwdkey {
    
    
 
    
    TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
  
    NSString *defaultStr = @"SCIENER";
    if (setClientPara.length > 0) {
        defaultStr = setClientPara;
    }
      Byte values[defaultStr.length];
    NSData *defaultData = [defaultStr dataUsingEncoding:NSUTF8StringEncoding];
    Byte *defaultBytes = (Byte *)[defaultData bytes];
    
    [TTDataTransformUtil arrayCopyWithSrc:defaultBytes srcPos:0 dst:values dstPos:0 length:defaultStr.length];
    
    [command setCommand:COMM_FETCH_AES_KEY];
    
    
    [command setDataAES:values withLength:defaultStr.length key:pwdkey];

    [self readyToWriteValueWithComand:command];
    
}

+(void)v3_resetLockWithversion:(NSString*)version
                                    key:(Byte*)pwdkey 
{
    
    
    TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
    Byte values[0];
    
    [command setCommand:COMM_LOCK_RESET];
    
    [command setDataAES:values withLength:0 key:pwdkey];
    
   [self readyToWriteValueWithComand:command];
    
    
}

// add admin
+(void)v3_add_admin_with_ps:(NSString*)password
                     number:(NSString*)unlocknumber
           version:(NSString*)version
                        key:(Byte*)pwdkey 
{
    
   
    TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
    Byte values[15]={
        0x0,0x0,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
    };
    
    
    long long psNumber = password.longLongValue;
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx",psNumber]];
    Byte *psByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:0 length:4];
    
    long long unlockNumberll = unlocknumber.longLongValue;
    NSData *unlocknumberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx",unlockNumberll]];
    Byte *unlockByte = (Byte *)[unlocknumberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:unlockByte  srcPos:0 dst:values dstPos:4 length:4];
    
    NSString *defaultStr = @"SCIENER";
    NSData *defaultData = [defaultStr dataUsingEncoding:NSUTF8StringEncoding];
    Byte *defaultBytes = (Byte *)[defaultData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:defaultBytes srcPos:0 dst:values dstPos:8 length:7];

    [command setCommand:COMM_ADD_ADMIN];
    
    [command setDataAES:values withLength:15 key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
    
}

// check admin
+(void)v3_check_admin_with_ps:(NSString*)password
                         flag:(int)flag
                       userID:(NSString *)userid
             version:(NSString*)version
                          key:(Byte*)pwdkey {
    
 
    
   TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
    Byte values[11]={
        0x0,0x0,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0,0x0
    };
    
    long long psNumber = password.longLongValue;
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx",psNumber]];
    Byte *psByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:0 length:4];
    
    
    
    NSData *unlocknumberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%06x",flag]];
    Byte *unlockByte = (Byte *)[unlocknumberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:unlockByte  srcPos:0 dst:values dstPos:4 length:3];
    
    //userID
    long long userID = userid.longLongValue;
    NSData *userIDData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx", userID]];
    Byte *userIDByte = (Byte *)[userIDData bytes];
   
    [TTDataTransformUtil arrayCopyWithSrc:userIDByte srcPos:0 dst:values dstPos:7 length:4];
   
    [command setCommand:COMM_ADD_USER];
    
    [command setDataAES:values withLength:11 key:pwdkey];
    [self readyToWriteValueWithComand:command];
    
    
}

// unlock  --flag(’0x00’,无操作;’0x01’, 设置无钥匙密码;’0x02’,校准时钟;'0x03',同步当前有效密码序列)
// psCurrent当前有效密码序列组
+(void)v3_unlock_with_psFromLock:(long long)psFromLock
                         psLocal:(long long)psLocal
                            uniqueid:(long long)uniqueid
                version:(NSString*)version
                             key:(Byte*)pwdkey 
{
    
    
    NSString *sum = [self getUnlockPassword:psFromLock localPassword:psLocal];
    
    
   TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];

    Byte values[8]={
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    };
    
    long long psNumber = sum.longLongValue;
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx",psNumber]];
    Byte *psByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:0 length:4];
  
    NSData *unlocknumberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx",uniqueid]];
    Byte *unlockByte = (Byte *)[unlocknumberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:unlockByte  srcPos:0 dst:values dstPos:4 length:4];
    
    
    [command setCommand:COMM_LOCK_UNLOCK];
    [command setDataAES:values withLength:8 key:pwdkey];
    
    
    [self readyToWriteValueWithComand:command];
    
}

+(void)click_Remote_Control_with_psFromLock:(long long)psFromLock
                         psLocal:(long long)psLocal
                        uniqueid:(long long)uniqueid
                     buttonValue:(int)buttonValue
                         version:(NSString*)version
                             key:(Byte*)pwdkey
{
    
    
    NSString *sum = [self getUnlockPassword:psFromLock localPassword:psLocal];
    
    
    TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
    Byte values[10];
    
    values[0] = 2;
    
    long long psNumber = sum.longLongValue;
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx",psNumber]];
    Byte *psByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:1 length:4];
    
    NSData *unlocknumberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx",uniqueid]];
    Byte *unlockByte = (Byte *)[unlocknumberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:unlockByte  srcPos:0 dst:values dstPos:5 length:4];
    
    values[9] = buttonValue;
    
    [command setCommand:LOCK_V3_COMM_Remote_Control];
    [command setDataAES:values withLength:10 key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
}
+ (void)setHotelICKey:(NSData *)ickey
         version:(NSString*)version
             key:(Byte*)pwdkey{
    
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    Byte values[9];
    values[0] = 2;
    values[1] = 1;
    values[2] = 6;
    Byte *psByte = (Byte *)[ickey bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:values dstPos:3 length:6];
    [command setCommand:LOCK_V3_COMM_HOTEL_CARD];
    [command setDataAES:values withLength:9 key:pwdkey];
    [self readyToWriteValueWithComand:command];
    
}

+ (void)setHotelAESKey:(NSData *)aesKey
          version:(NSString*)version
              key:(Byte*)pwdkey{
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    Byte values[19];
    values[0] = 2;
    values[1] = 2;
    values[2] = 16;
    Byte *psByte = (Byte *)[aesKey bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:values dstPos:3 length:16];
    [command setCommand:LOCK_V3_COMM_HOTEL_CARD];
    [command setDataAES:values withLength:19 key:pwdkey];
    [self readyToWriteValueWithComand:command];


}
+ (void)setHotelNumber:(NSString *)hotelNumber
        buildingNumber:(NSString *)buildingNumber
           floorNumber:(NSString *)floorNumber
               version:(NSString*)version
                   key:(Byte*)pwdkey{
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    Byte values[8];
    values[0] = 2;
    values[1] = 3;
    values[2] = 5;
    long long hotelNum = hotelNumber.longLongValue;
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%06llx",hotelNum]];;
    Byte *psByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:3 length:3];
    values[6] = buildingNumber.intValue;
    values[7] = floorNumber.intValue;
    [command setCommand:LOCK_V3_COMM_HOTEL_CARD];
    [command setDataAES:values withLength:8 key:pwdkey];
    [self readyToWriteValueWithComand:command];
}
+ (void)queryHotelICKeyWithType:(int)type
                        version:(NSString*)version
                   key:(Byte*)pwdkey{
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    Byte values[2];
    values[0] = 1;
    values[1] = type;
    [command setCommand:LOCK_V3_COMM_HOTEL_CARD];
    [command setDataAES:values withLength:2 key:pwdkey];
    [self readyToWriteValueWithComand:command];
    
}
//闭(guan)锁
+(void)v3_lock_with_psFromLock:(long long)psFromLock
                         psLocal:(long long)psLocal
                        uniqueid:(long long)uniqueid
                         version:(NSString*)version
                             key:(Byte*)pwdkey
{
    
    
    NSString *sum = [self getUnlockPassword:psFromLock localPassword:psLocal];
    
    
    TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
    Byte values[8]={
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    };
    
    long long psNumber = sum.longLongValue;
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx",psNumber]];
    Byte *psByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:0 length:4];
    

    NSData *unlocknumberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx",uniqueid]];
    Byte *unlockByte = (Byte *)[unlocknumberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:unlockByte  srcPos:0 dst:values dstPos:4 length:4];
    
    
    [command setCommand:Lock_V3_COMM_LOCK];
    [command setDataAES:values withLength:8 key:pwdkey];
    
    
    [self readyToWriteValueWithComand:command];
    
}
//随机数验证
+(void)v3_check_random_with_psFromLock:(long long)psFromLock
                         psLocal:(long long)psLocal
                         version:(NSString*)version
                             key:(Byte*)pwdkey 
{
    

    
    NSString *sum = [self getUnlockPassword:psFromLock localPassword:psLocal];
    
    TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
    Byte values[4]={
        0x00,0x00,0x00,0x00
    };
    
    long long psNumber = sum.longLongValue;
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx",psNumber]];
    Byte *psByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:0 length:4];
    
    
    [command setCommand:LOCK_V3_COMM_CHECK_RANDOM];
    
    
    [command setDataAES:values withLength:4 key:pwdkey];
    
    
    [self readyToWriteValueWithComand:command];
    
    
}

//普通用户时效性检测
//TODO 实效flag一个字节太短了，3个字节可以
+(void)v3_check_user_with_startDate:(NSString*)startDate
                            endDate:(NSString*)endDate
                               flag:(int)flag
                             userID:(NSString *)userid
                  version:(NSString*)version
                                key:(Byte*)pwdkey 
{
    
     TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
    Byte values[17]={
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00
    };
    
    // start date
    {
        
        NSArray * timeArray = [startDate componentsSeparatedByString:@"-"];
        for (int i = 0 ; i < timeArray.count ; i ++) {
            
            int unlockNumber = ((NSString *)timeArray[i]).intValue;
            
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",unlockNumber]];
            
            Byte *numberByte = (Byte *)[numberData bytes];
            values[i] = numberByte[0];
            
        }
        
    }
    
    // end date
    {
        
        NSArray * timeArray = [endDate componentsSeparatedByString:@"-"];
        for (int i = 0 ; i < timeArray.count ; i ++) {
            
            int unlockNumber = ((NSString *)timeArray[i]).intValue;
            
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",unlockNumber]];
            
            Byte *numberByte = (Byte *)[numberData bytes];
            values[5+i] = numberByte[0];
            
        }
        
    }
    
    //flag
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%06x",flag]];
    Byte *numberByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:numberByte  srcPos:0 dst:values dstPos:10 length:3];
    
    //userID
    long long  userID = userid.longLongValue;
    NSData *userIDData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx", userID]];
    Byte *userIDByte = (Byte *)[userIDData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:userIDByte srcPos:0 dst:values dstPos:13 length:4];
    
    [command setCommand:COMM_LOCK_CHECK_USER_TIME];
    
    [command setDataAES:values withLength:17 key:pwdkey];
    
   [self readyToWriteValueWithComand:command];
    
    
}

////设备参数设置/查询
+(void)v3_device_parameter_settings_ATCommand:(NSString *)ATCommand
                             version:(NSString*)version
                                          key:(Byte*)pwdkey {
  
    
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    
    NSData *ATCommandData = [ATCommand dataUsingEncoding:NSUTF8StringEncoding];
    Byte *ATCommandByte = (Byte *)[ATCommandData bytes];
    
    [command setCommand:COMM_LOCK_Device_Parameter_Settings];
    [command setDataAES:ATCommandByte withLength:(int)ATCommandData.length key:pwdkey];
    
    [self readyToWriteValueWithComand:command];

}
+ (void)v3_get_lockTimeWithversion:(NSString*)version
                                    key:(Byte*)pwdkey 
{
    
    
   TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
    Byte values[0];
    
    [command setCommand:Lock_V3_COMM_GET_LOCK_TIME];
    
    [command setDataAES:values withLength:0 key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
    
    
}
//修改或恢复密码
+(void)v3_modify_Recover_keyboard_password_operateType:(TTOprationType)operateType
                                          keyboardType:(TTPasscodeType)keyboardType
                                             cycleType:(NSInteger)cycleType
                                           oldPassword:(NSString *)oldPassword
                                           newPassword:(NSString *)newPassword
                                             startDate:(NSDate *)startDate
                                               endDate:(NSDate*)endDate
                                     timezoneRawOffset:(long)timezoneRawOffset
                                               version:(NSString*)version
                                                   key:(Byte*)pwdkey{
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    [command setCommand:COMM_USER_PS_SET_DEL];
    NSInteger dataLen = 4+oldPassword.length+newPassword.length;
    if (startDate != nil) {
        dataLen = dataLen + 5;
    }
    if (endDate != nil) {
        dataLen = dataLen + 5;
    }
    //如果是循环类型 后边要加两字节的循环方式
    if (keyboardType == TTPasscodeTypeCycle) {
        dataLen = dataLen + 2;
    }
    Byte values[dataLen];
    
    
    //修改 原密码在前  新密码在后  恢复 原密码在后 新密码在前                                                                                                                                                                                                                             
    if (operateType == TTOprationTypeModify) {
        //修改的类型是5
        values[0] = 0x05;
        values[1] = 1; //这个是任意
        
        values[2] = oldPassword.length;
        
        NSData *oldPwdData = [oldPassword dataUsingEncoding:NSUTF8StringEncoding];
        Byte *oldByte = (Byte *)[oldPwdData bytes];
        [TTDataTransformUtil arrayCopyWithSrc:oldByte srcPos:0 dst:values dstPos:3 length:oldPassword.length];
        
        values[3+oldPassword.length] = newPassword.length;
        //新密码可以为nil
        if (newPassword.length > 0) {
            NSData *newPwdData = [newPassword dataUsingEncoding:NSUTF8StringEncoding];
            Byte *newByte = (Byte *)[newPwdData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:newByte srcPos:0 dst:values dstPos:4+oldPassword.length length:newPassword.length];
        }
 
    }
    
    if (operateType == TTOprationTypeRecover) {
        //恢复的类型是6
        values[0] = 0x06;
        switch (keyboardType) {
            case TTPasscodeTypeOnce:
                 keyboardType = TTPasscodeTypePermanent;
                break;
            case TTPasscodeTypePermanent:
                keyboardType = TTPasscodeTypeOnce;
                break;
            default:
                break;
        }
       
        values[1] = keyboardType;
        
        values[2] = newPassword.length;
        NSData *newPwdData = [newPassword dataUsingEncoding:NSUTF8StringEncoding];
        Byte *newByte = (Byte *)[newPwdData bytes];
        [TTDataTransformUtil arrayCopyWithSrc:newByte srcPos:0 dst:values dstPos:3 length:newPassword.length];
        
         values[3+newPassword.length] = oldPassword.length;
        NSData *oldPwdData = [oldPassword dataUsingEncoding:NSUTF8StringEncoding];
        Byte *oldByte = (Byte *)[oldPwdData bytes];
        [TTDataTransformUtil arrayCopyWithSrc:oldByte srcPos:0 dst:values dstPos: 4+newPassword.length length:oldPassword.length];
        
        
    }
   
    //时间
    NSString *timestr = [NSString string];
    if (startDate != nil && endDate != nil) {
        timestr = [NSString stringWithFormat:@"%@-%@",[TTDateHelper formateDate:startDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:timezoneRawOffset],[TTDateHelper formateDate:endDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:timezoneRawOffset]] ;
        
    }else if (startDate != nil){
        timestr = [TTDateHelper formateDate:startDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:timezoneRawOffset];
    }else if (endDate != nil){
        timestr =   [TTDateHelper formateDate:endDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:timezoneRawOffset];
    }
    
    if (timestr.length > 0) {
        NSArray * timeArray = [timestr componentsSeparatedByString:@"-"];//@"yy-MM-dd-HH-mm"
        for (int i = 0 ; i < timeArray.count ; i ++) {
            
            int number = ((NSString *)timeArray[i]).intValue;
            
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",number]];
            
            Byte *numberByte = (Byte *)[numberData bytes];
            values[i+4+oldPassword.length+newPassword.length] = numberByte[0];
        }
        
    }
    //如果是循环类型 后边要加两字节的循环方式
    if (keyboardType == TTPasscodeTypeCycle) {
       
        NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04lx",(long)cycleType]];
        Byte *psByte = (Byte *)[numberData bytes];
        
        [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:dataLen - 2 length:2];
        
    }
    [command setDataAES:values withLength:dataLen key:pwdkey];
    
    [self readyToWriteValueWithComand:command];

    
}


//修改锁名
+(void)v3_set_lock_name_name:(NSString *)name
              version:(NSString*)version
                         key:(Byte*)pwdkey {
    
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    NSData *nameData = [name dataUsingEncoding:NSUTF8StringEncoding];
    Byte *nameByte = (Byte *)[nameData bytes];
    
    [command setCommand:LOCK_V3_COMM_SET_LOCK_NAME];
    [command setDataAES:nameByte withLength:nameData.length key:pwdkey];
    [self readyToWriteValueWithComand:command];
    
}

//设置同时有效密码数
+(void)v3_set_max_number_of_keyboard_password_number:(int)number
                                    version:(NSString*)version
                                        key:(Byte*)pwdkey {
    
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    Byte values[1];
    
    values[0] = number;
    
    [command setCommand:Lock_V3_COMM_SET_MAX_NUMBER_OF_KEYBOARD_PASSWOED];
    [command setDataAES:values withLength:1 key:pwdkey];
   [self readyToWriteValueWithComand:command];
    
}


// 校准时间
+(void)v3_calibation_time_with_version:(NSString*)version
                                  referenceTime:(NSString *)referenceTime
                                            key:(Byte*)pwdkey 
{
  
    
   TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
    Byte values[6]={
        0x00,0x00,0x00,0x00,0x00,0x00
    };
    NSArray * timeArray = [referenceTime componentsSeparatedByString:@"-"];
    for (int i = 0 ; i < timeArray.count ; i ++) {
        
        int number = ((NSString *)timeArray[i]).intValue;
        
        NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",number]];
        
        Byte *numberByte = (Byte *)[numberData bytes];
        values[i] = numberByte[0];
        
    }
    
    [command setCommand:COMM_LOCK_TIME_CALIBRATION];
    
    [command setDataAES:values withLength:6 key:pwdkey];
    
   [self readyToWriteValueWithComand:command];    
    
}

//设置管理员无钥匙密码
+(void)v3_set_admin_nokey_ps:(NSString*)password
           version:(NSString*)version
                         key:(Byte*)pwdkey 
{
    
   TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
    Byte sPsByte[password.length];
    
    for (int i = 0 ; i < password.length; i ++) {
        
        NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",[password characterAtIndex:i]-'0']];

        Byte *numberByte = (Byte *)[numberData bytes];
        sPsByte[i] = numberByte[0];
        
    }

    [command setCommand:COMM_LOCK_SET_ADMIN_PS];
    
    [command setDataAES:sPsByte withLength:password.length key:pwdkey];
    
   [self readyToWriteValueWithComand:command];    
    
}

/**设置管理员密码。管理员密码：7到10位
 */
+(void)v2_aes_set_admin_nokey_ps:(NSString*)password
                version:(NSString*)version
                             key:(Byte*)pwdkey
                     
{
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    Byte values[10] = {
        0xFF,0xFF,0xFF,0xFF,0xFF,
        0xFF,0xFF,0xFF,0xFF,0xFF
    };
    
    //    NSData *psData = [password dataUsingEncoding: NSUTF8StringEncoding];
    //    Byte *psByte = (Byte *)[psData bytes];
    
    Byte psByte[password.length];
    for (int i = 0 ; i < password.length; i ++) {
        
        NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",[password characterAtIndex:i]-'0']];
        
        Byte *numberByte = (Byte *)[numberData bytes];
        psByte[i] = numberByte[0];
        
    }
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:0 length:password.length];

    
    [command setCommand:COMM_LOCK_SET_ADMIN_PS];
    
    [command setDataAES:values withLength:10 key:pwdkey];
    
    [self readyToWriteValueWithComand:command];

}

//修改蓝牙名称
+(void)v3_rename:(NSString*)name
     WithVersion:(NSString*)version
             key:(Byte*)pwdkey 
{
    
    
   TTCommand *command = [[TTCommand alloc]init];
    
    
    [command commandWithVersion:version];
    
    [command setCommand:LOCK_V3_COMM_RENAME];
    
    NSData *nameData = [name dataUsingEncoding:NSUTF8StringEncoding];
    Byte *nameByte = (Byte *)[nameData bytes];
    
    [command setDataAES:nameByte withLength:nameData.length key:pwdkey];
    
    
    [self readyToWriteValueWithComand:command];
    
}

//清空键盘密码
+(void)v3_clear_user_kbpwd_WithVersion:(NSString*)version  
                                        key:(Byte*)pwdkey 
{
    
    
   TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
    [command setCommand:COMM_USER_PS_SET_DEL];
    
    Byte datas[3];
    
    datas[0]=0x01;
    datas[1]=0x00;
    
    [command setDataAES:datas withLength:2 key:pwdkey];
    
    
   [self readyToWriteValueWithComand:command];
    
}

//删除键盘密码
+(void)v3_del_kbpwd:(NSString*)passwrod
             psType:(int)type
   version:(NSString*)version
                key:(Byte*)pwdkey 
{
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    [command setCommand:COMM_USER_PS_SET_DEL];
    
    Byte datas[3+passwrod.length];
    
    datas[0]=0x03;
    datas[1]=type;
    datas[2]=passwrod.length;
    NSData *nameData = [passwrod dataUsingEncoding:NSUTF8StringEncoding];
    Byte *nameByte = (Byte *)[nameData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:nameByte srcPos:0 dst:datas dstPos:3 length:passwrod.length];
    
    [command setDataAES:datas withLength:3+passwrod.length key:pwdkey];
    
    
   [self readyToWriteValueWithComand:command];
    
}


+(void)v3_clear_kbpwd_WithVersion:(NSString*)version key:(Byte*)pwdkey
{
    
   TTCommand *command = [[TTCommand alloc]init];
    
    
    [command commandWithVersion:version];
    
    [command setCommand:COMM_USER_PS_SET_DEL];
    
    Byte datas[1];
    
    datas[0]=0x01;
    
    [command setDataAES:datas withLength:1 key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
    
}

+(void)v3_get_device_characteristic_WithVersion:(NSString*)version  {
    
   TTCommand *command = [[TTCommand alloc]init];
    Byte values[0];
    [command commandWithVersion:version];
    [command setCommand:Lock_V3_COMM_GET_Device_CHARACTERISTIC];
    [command setData:values withLength:0];
    [self readyToWriteValueWithComand:command];
    
}
+(void)v3_set_Bong_Key:(NSString*)BongKey
           version:(NSString*)version
                   key:(Byte*)pwdkey {
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    NSData *psData = [BongKey dataUsingEncoding: NSUTF8StringEncoding];
    Byte *sPsByte = (Byte *)[psData bytes];
    [command setCommand:Lock_V3_COMM_SET_Bongkey];
    [command setDataAES:sPsByte withLength:(int)BongKey.length key:pwdkey];
    
   [self readyToWriteValueWithComand:command];
}

+(void)AddIC_version:(NSString*)version
                            key:(Byte*)pwdkey
                    {
    
   TTCommand *command = [[TTCommand alloc]init];
    
    
    [command commandWithVersion:version];
    
    [command setCommand:Lock_V3_COMM_IC_Manager];
    
    Byte datas[1];
    datas[0]=0x02;
    
    [command setDataAES:datas withLength:1 key:pwdkey];
    
   [self readyToWriteValueWithComand:command];
    
}
+(void)ClearIC_version:(NSString*)version
                            key:(Byte*)pwdkey
                    {
    
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    [command setCommand:Lock_V3_COMM_IC_Manager];
    
    Byte datas[1];
    datas[0]=0x04;
    
    [command setDataAES:datas withLength:1 key:pwdkey];
    
   [self readyToWriteValueWithComand:command];
}
+(void)DeleteIC_ICNumber:(NSString*)ICNumber
          version:(NSString*)version  
                       key:(Byte*)pwdkey
             {
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    [command setCommand:Lock_V3_COMM_IC_Manager];
     //为了兼容身份证
    int addLengh = ICNumber.length > 10 ? 4 : 0;
    Byte datas[5 + addLengh];
    datas[0]=0x03;
                 
    long long icnum = ICNumber.longLongValue;
    NSData *numberData = addLengh > 0 ? [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%llx",icnum]] : [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx",icnum]];
    Byte *psByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:datas dstPos:1 length:4 + addLengh];
    
    [command setDataAES:datas withLength:5 + addLengh key:pwdkey];
    
   [self readyToWriteValueWithComand:command];
}
+(void)ModifyOrRecoverICWithType:(NSInteger)type
                        ICNumber:(NSString*)ICNumber
                       startDate:(NSString*)startDate
                         endDate:(NSString*)endDate
                         version:(NSString*)version
                             key:(Byte*)pwdkey{
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    [command setCommand:Lock_V3_COMM_IC_Manager];
    //为了兼容身份证
    int addLengh = ICNumber.length > 10 ? 4 : 0;
    Byte datas[15 + addLengh];
    
    //类型 1-查询，2-添加，3-删除 4-清空 5-修改
    datas[0]= type;
    
    long long  icnum = ICNumber.longLongValue;
    NSData *numberData = addLengh > 0 ? [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%llx",icnum]] : [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx",icnum]];
    Byte *psByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:datas dstPos:1 length:4 + addLengh];
    
    {
        
        NSArray * timeArray = [startDate componentsSeparatedByString:@"-"];
        for (int i = 0 ; i < timeArray.count ; i ++) {
            
            int unlockNumber = ((NSString *)timeArray[i]).intValue;
            
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",unlockNumber]];
            
            Byte *numberByte = (Byte *)[numberData bytes];
            datas[5+ addLengh +i] = numberByte[0];
            
        }
        
    }
    
    // end date
    {
        
        NSArray * timeArray = [endDate componentsSeparatedByString:@"-"];
        for (int i = 0 ; i < timeArray.count ; i ++) {
            int unlockNumber = ((NSString *)timeArray[i]).intValue;
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",unlockNumber]];
            Byte *numberByte = (Byte *)[numberData bytes];
            datas[10 + addLengh +i] = numberByte[0];
            
        }
        
    }
    
    [command setDataAES:datas withLength:15 + addLengh key:pwdkey];
    
    [self readyToWriteValueWithComand:command];

}


+(void)AddFingerprint_WithVersion:(NSString*)version
                              key:(Byte*)pwdkey{
    
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    [command setCommand:Lock_V3_COMM_Fingerprint_Manager];
    
    Byte datas[1];
    datas[0]=0x02;
    
    [command setDataAES:datas withLength:1 key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
    
}
+(void)DeleteFingerprint_FingerprintNumber:(NSString*)FingerprintNumber
                 version:(NSString*)version
                     key:(Byte*)pwdkey
{
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    [command setCommand:Lock_V3_COMM_Fingerprint_Manager];
    Byte datas[7];
    datas[0]=0x03;
    long long icnum = FingerprintNumber.longLongValue;
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%012llx",icnum]];
    Byte *psByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:datas dstPos:1 length:6];
    [command setDataAES:datas withLength:7 key:pwdkey];
    [self readyToWriteValueWithComand:command];
}
+(void)ClearFingerprint_version:(NSString*)version
                   key:(Byte*)pwdkey
{
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    [command setCommand:Lock_V3_COMM_Fingerprint_Manager];
    Byte datas[1];
    datas[0]=0x04;
    [command setDataAES:datas withLength:1 key:pwdkey];
    [self readyToWriteValueWithComand:command];
}
+(void)ModifyOrRecoverFingerprintWithType:(NSInteger)type
                        FingerprintNumber:(NSString*)FingerprintNumber
                                startDate:(NSString*)startDate
                                  endDate:(NSString*)endDate
                                  version:(NSString*)version
                                      key:(Byte*)pwdkey{
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    [command setCommand:Lock_V3_COMM_Fingerprint_Manager];
    
    Byte datas[17];
    datas[0] = type;
    long long icnum = FingerprintNumber.longLongValue;
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%012llx",icnum]];
    Byte *psByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:datas dstPos:1 length:6];
    
    {
        
        NSArray * timeArray = [startDate componentsSeparatedByString:@"-"];
        for (int i = 0 ; i < timeArray.count ; i ++) {
            
            int unlockNumber = ((NSString *)timeArray[i]).intValue;
            
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",unlockNumber]];
            
            Byte *numberByte = (Byte *)[numberData bytes];
            datas[7+i] = numberByte[0];
            
        }
        
    }
    
    // end date
    {
        
        NSArray * timeArray = [endDate componentsSeparatedByString:@"-"];
        for (int i = 0 ; i < timeArray.count ; i ++) {
            
            int unlockNumber = ((NSString *)timeArray[i]).intValue;
            
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",unlockNumber]];
            
            Byte *numberByte = (Byte *)[numberData bytes];
            datas[12+i] = numberByte[0];
            
        }
        
    }
    
    [command setDataAES:datas withLength:17 key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
}
+(void)recoverFingerprintDataWithTempNumber:(NSString*)tempNumber
                                 fingernumberDataStr:(NSString*)fingernumberDataStr
                                startDate:(NSString*)startDate
                                  endDate:(NSString*)endDate
                                  version:(NSString*)version
                                      key:(Byte*)pwdkey{
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    [command setCommand:Lock_V3_COMM_Fingerprint_Manager];
    Byte datas[19];
    
    datas[0] = TTOprationTypeAdd;
    
    long long icnum = tempNumber.longLongValue;
    NSData *tempNumberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx",icnum]];
    Byte *psByte = (Byte *)[tempNumberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:datas dstPos:1 length:4];
    
    NSData *fingernumberData = [TTDataTransformUtil DataFromHexStr:fingernumberDataStr];
    NSInteger dataLength = fingernumberData.length;
    
    NSData *lengthNumberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04lx",(long)dataLength]];
    Byte *fingerLengthByte = (Byte *)[lengthNumberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:fingerLengthByte srcPos:0 dst:datas dstPos:5 length:2];
    
    long long sum = 0;
    Byte *fingerDataByte = (Byte *)[fingernumberData bytes];
    for (int i = 0; i < dataLength; i++) {
        sum += [TTDataTransformUtil intFromHexBytes:&fingerDataByte[i] length:1];
    }
    sum = sum & 0xffff;
    NSData *sumData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04llx",sum]];
    Byte *sumDataByte = (Byte *)[sumData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:sumDataByte srcPos:0 dst:datas dstPos:7 length:2];
    
    
    {
        
        NSArray * timeArray = [startDate componentsSeparatedByString:@"-"];
        for (int i = 0 ; i < timeArray.count ; i ++) {
            
            int unlockNumber = ((NSString *)timeArray[i]).intValue;
            
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",unlockNumber]];
            
            Byte *numberByte = (Byte *)[numberData bytes];
            datas[9+i] = numberByte[0];
            
        }
        
    }
    
    // end date
    {
        
        NSArray * timeArray = [endDate componentsSeparatedByString:@"-"];
        for (int i = 0 ; i < timeArray.count ; i ++) {
            
            int unlockNumber = ((NSString *)timeArray[i]).intValue;
            
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",unlockNumber]];
            
            Byte *numberByte = (Byte *)[numberData bytes];
            datas[14+i] = numberByte[0];
            
        }
    }
    
    [command setDataAES:datas withLength:19 key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
}

+(void)recoverFingerprintDataWithFingernumberDataStr:(NSString*)fingernumberDataStr
                                               index:(int)index
                                            maxCount:(int)maxCount
                                             version:(NSString*)version
                                                 key:(Byte*)pwdkey{
    
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    [command setCommand:Lock_V3_COMM_Fingerprint_Manager];
    
    NSData *fingernumberData = [TTDataTransformUtil DataFromHexStr:fingernumberDataStr];
    Byte *fingernumberDataByte = (Byte *)[fingernumberData bytes];
    
    int totalLength =  (int)fingernumberData.length;
    
    int currentMaxCount = maxCount;
    //已经传完了，不继续传
    if (index * maxCount  >= totalLength) {
      
        return;
       
    }
    
//    除了最后一个数据包，每次都填充最大允许的数据包字节个数。
    if (index * maxCount + maxCount >= totalLength) {
        
        currentMaxCount = totalLength - index * maxCount;
     
    }
   
    
     Byte datas[3 + currentMaxCount];
     datas[0] = TTOprationTypeAddFingerprintData;
    
    NSData *indexData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",index]];
    Byte *psByte = (Byte *)[indexData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:datas dstPos:1 length:2];
    
    [TTDataTransformUtil arrayCopyWithSrc:fingernumberDataByte srcPos:index*maxCount dst:datas dstPos:3 length:currentMaxCount];

    [command setDataAES:datas withLength:3 + currentMaxCount key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
}

+ (void)setNBServerConfigWithPortNumber:(NSString*)portNumber
                          serverAddress:(NSString*)serverAddress
                                version:(NSString*)version
                                    key:(Byte*)pwdkey{
    
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    [command setCommand:COMM_NBServer_Config];
    
    Byte datas[2+serverAddress.length];
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",portNumber.intValue]];
    Byte *psByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:0 length:2];
    
    NSData *psData = [serverAddress dataUsingEncoding: NSUTF8StringEncoding];
    Byte *sPsByte = (Byte *)[psData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:sPsByte srcPos:0 dst:datas dstPos:2 length:serverAddress.length];
    
    [command setDataAES:datas withLength:2 + serverAddress.length key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
    
}

+ (void)setPassageModeWithType:(TTPassageModeType)type
                     weekOrDay:(int)weekOrDay
                         month:(int)month
                     startDate:(int)startDate
                       endDate:(int)endDate
                       version:(NSString*)version
                           key:(Byte*)pwdkey{
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    [command setCommand:LOCK_V3_COMM_PASSAGEMODE];
    Byte datas[8];
    datas[0] = 2;
    datas[1] = type;
    datas[2] = weekOrDay;
    datas[3] = month;
    datas[4] = startDate/60;
    datas[5] = startDate % 60;
    datas[6] = endDate/60;
    datas[7] = endDate % 60;
    [command setDataAES:datas withLength:8 key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
}

+(void)noneRequestStringPara_WithVersion:(NSString*)version
                            commandValue:(Byte)commandValue
                                     key:(Byte*)pwdkey{
    
    TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
    [command setCommand:commandValue];
    
    Byte datas[0];
    [command setDataAES:datas withLength:0 key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
}
+(void)oneRequestPara_WithVersion:(NSString*)version
                      requestPara:(int)requestPara
                       Paralength:(int)Paralength
                         commandValue:(Byte)commandValue
                              key:(Byte*)pwdkey{
    
   TTCommand *command = [[TTCommand alloc]init];
   [command commandWithVersion:version];
   [command setCommand:commandValue];
    
    Byte datas[Paralength];
    
    switch (Paralength) {
        case 1:
            datas[0]= requestPara;
            break;
        case 2:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",requestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:0 length:Paralength];
        }break;
        case 3:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%06x",requestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:0 length:Paralength];
        }break;
        default:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08x",requestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:0 length:Paralength];
        } break;
    }
   
   
    [command setDataAES:datas withLength:Paralength key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
}
+(void)twoRequestPara_WithVersion:(NSString*)version
                      requestPara:(int)requestPara
                   tworequestPara:(int)tworequestPara
                       Paralength:(int)Paralength
                    twoParalength:(int)twoParalength
                     commandValue:(Byte)commandValue
                              key:(Byte*)pwdkey{
    
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    [command setCommand:commandValue];
    
    Byte datas[Paralength+twoParalength];
    
    switch (Paralength) {
        case 1:
            datas[0]= requestPara;
            break;
        case 2:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",requestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:0 length:Paralength];
        }break;
        case 3:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%06x",requestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:0 length:Paralength];
        }break;
        default:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08x",requestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:0 length:Paralength];
        } break;
    }
    
    switch (twoParalength) {
        case 1:
            datas[Paralength]= tworequestPara;
            break;
        case 2:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",tworequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength length:twoParalength];
        }break;
        case 3:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%06x",tworequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength length:twoParalength];
        }break;
        default:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08x",tworequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength length:twoParalength];
        } break;
    }
    
    [command setDataAES:datas withLength:Paralength+twoParalength key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
}
+(void)threeRequestPara_WithVersion:(NSString*)version
                      requestPara:(int)requestPara
                   tworequestPara:(int)tworequestPara
                   threerequestPara:(int)threerequestPara
                       Paralength:(int)Paralength
                    twoParalength:(int)twoParalength
                      threeParalength:(int)threeParalength
                     commandValue:(Byte)commandValue
                              key:(Byte*)pwdkey{
    
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    [command setCommand:commandValue];
    
    Byte datas[Paralength+twoParalength+threeParalength];
    
    switch (Paralength) {
        case 1:
            datas[0]= requestPara;
            break;
        case 2:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",requestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:0 length:Paralength];
        }break;
        case 3:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%06x",requestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:0 length:Paralength];
        }break;
        default:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08x",requestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:0 length:Paralength];
        } break;
    }
    
    switch (twoParalength) {
        case 1:
            datas[Paralength]= tworequestPara;
            break;
        case 2:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",tworequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength length:twoParalength];
        }break;
        case 3:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%06x",tworequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength length:twoParalength];
        }break;
        default:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08x",tworequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength length:twoParalength];
        } break;
    }
    switch (threeParalength) {
        case 1:
            datas[Paralength+twoParalength]= threerequestPara;
            break;
        case 2:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",threerequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength+twoParalength length:threeParalength];
        }break;
        case 3:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%06x",threerequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength+twoParalength length:threeParalength];
        }break;
        default:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08x",threerequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength+twoParalength length:threeParalength];
        } break;
    }
    
    [command setDataAES:datas withLength:Paralength+twoParalength+threeParalength key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
}
+(void)fourRequestPara_WithVersion:(NSString*)version
                       requestPara:(int)requestPara
                    tworequestPara:(int)tworequestPara
                  threerequestPara:(int)threerequestPara
                   fourrequestPara:(int)fourrequestPara
                        Paralength:(int)Paralength
                     twoParalength:(int)twoParalength
                   threeParalength:(int)threeParalength
                    fourParalength:(int)fourParalength
                      commandValue:(Byte)commandValue
                               key:(Byte*)pwdkey{
    TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    [command setCommand:commandValue];
    
    Byte datas[Paralength+twoParalength+threeParalength];
    
    switch (Paralength) {
        case 1:
            datas[0]= requestPara;
            break;
        case 2:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",requestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:0 length:Paralength];
        }break;
        case 3:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%06x",requestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:0 length:Paralength];
        }break;
        default:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08x",requestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:0 length:Paralength];
        } break;
    }
    
    switch (twoParalength) {
        case 1:
            datas[Paralength]= tworequestPara;
            break;
        case 2:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",tworequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength length:twoParalength];
        }break;
        case 3:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%06x",tworequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength length:twoParalength];
        }break;
        default:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08x",tworequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength length:twoParalength];
        } break;
    }
    switch (threeParalength) {
        case 1:
            datas[Paralength+twoParalength]= threerequestPara;
            break;
        case 2:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",threerequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength+twoParalength length:threeParalength];
        }break;
        case 3:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%06x",threerequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength+twoParalength length:threeParalength];
        }break;
        default:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08x",threerequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength+twoParalength length:threeParalength];
        } break;
    }
    switch (fourParalength) {
        case 1:
            datas[Paralength+twoParalength+threeParalength]= fourrequestPara;
            break;
        case 2:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",threerequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength+twoParalength+threeParalength length:fourrequestPara];
        }break;
        case 3:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%06x",threerequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength+twoParalength+threeParalength length:fourrequestPara];
        }break;
        default:{
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08x",threerequestPara]];
            Byte *psByte = (Byte *)[numberData bytes];
            [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:Paralength+twoParalength+threeParalength length:fourrequestPara];
        } break;
    }
    [command setDataAES:datas withLength:Paralength+twoParalength+threeParalength+fourParalength key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
}

+(void)oneRequestStringPara_WithVersion:(NSString*)version
                            requestPara:(NSString*)requestPara
                           commandValue:(Byte)commandValue
                                    key:(Byte*)pwdkey{
    
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    [command setCommand:commandValue];
    
    NSInteger ParaLength = requestPara.length;
    Byte datas[ParaLength];
    NSData *numberData = [requestPara dataUsingEncoding:NSUTF8StringEncoding];
    Byte *psByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte srcPos:0 dst:datas dstPos:0 length:ParaLength];
    
    [command setDataAES:datas withLength:(int)ParaLength key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
}

/**********************V2 AES*******************************/

+(void)v2_aes_fetchLockAesKeyWithVersion:(NSString*)version  
                                              key:(Byte*)pwdkey {
    
    
    
   TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
    Byte values[0];
    
    [command setCommand:COMM_FETCH_AES_KEY];
    [command setDataAES:values withLength:0 key:pwdkey];

    [self readyToWriteValueWithComand:command];

    
}
// add admin
+(void)v2_aes_add_admin_with_ps:(NSString*)password
                     number:(NSString*)unlocknumber
           version:(NSString*)version
                        key:(Byte*)pwdkey 
{
    
    
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    Byte values[14]={
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00
    };
    
    
    Byte psByte[password.length];
    for (int i = 0 ; i < password.length; i ++) {
        
        NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",[password characterAtIndex:i]-'0']];
        
        Byte *numberByte = (Byte *)[numberData bytes];
        psByte[i] = numberByte[0];
        
    }
       [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:10-password.length length:10];
    
    //注释：
    //  14 99 02 38  hex
    //  转换之后：
    //  14 99 02 38
    
    long long unlockNumber = unlocknumber.longLongValue;
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx",unlockNumber]];
    Byte *numberByte = (Byte *)[numberData bytes];

    [TTDataTransformUtil arrayCopyWithSrc:numberByte  srcPos:0 dst:values dstPos:10 length:4];

    [command setCommand:COMM_ADD_ADMIN];
    
    [command setDataAES:values withLength:14 key:pwdkey];
    [self readyToWriteValueWithComand:command];
    
    
}

+(void)v2_aes_check_admin_with_ps:(NSString*)password
                             flag:(int)flag
                version:(NSString*)version  
                              key:(Byte*)pwdkey  {
    
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    Byte values[13]={
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00};
    Byte psByte[password.length];
    for (int i = 0 ; i < password.length; i ++) {
        
        NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",[password characterAtIndex:i]-'0']];
        
        Byte *numberByte = (Byte *)[numberData bytes];
        psByte[i] = numberByte[0];
        
    }

    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:10-password.length length:password.length];
    
    NSData *unlocknumberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",flag]];
    Byte *unlockByte = (Byte *)[unlocknumberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:unlockByte  srcPos:0 dst:values dstPos:13-unlocknumberData.length length:unlocknumberData.length];
    
    
    [command setCommand:COMM_ADD_USER];
    
    [command setDataAES:values withLength:13 key:pwdkey];
    
   [self readyToWriteValueWithComand:command];

}
+(void)v2_aes_check_user_with_startDate:(NSString*)startDate
                            endDate:(NSString*)endDate
                               flag:(int)flag
                  version:(NSString*)version
                                key:(Byte*)pwdkey 
{
    
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];

    //[command commandWithVersion:version];
    
    Byte values[13]={
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00
    };
    
    // start date
    {
        
        NSArray * timeArray = [startDate componentsSeparatedByString:@"-"];
        for (int i = 0 ; i < timeArray.count ; i ++) {
            
            int unlockNumber = ((NSString *)timeArray[i]).intValue;
            
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",unlockNumber]];
            
            Byte *numberByte = (Byte *)[numberData bytes];
            values[i] = numberByte[0];
            
        }
        
    }
    
    // end date
    {
        
        NSArray * timeArray = [endDate componentsSeparatedByString:@"-"];
        for (int i = 0 ; i < timeArray.count ; i ++) {
            
            int unlockNumber = ((NSString *)timeArray[i]).intValue;
            
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",unlockNumber]];
            
            Byte *numberByte = (Byte *)[numberData bytes];
            values[5+i] = numberByte[0];
            
        }
        
    }
    
    //flag
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",flag]];
    Byte *numberByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:numberByte  srcPos:0 dst:values dstPos:13-numberData.length length:numberData.length];
    
    [command setCommand:COMM_LOCK_CHECK_USER_TIME];
    
    [command setDataAES:values withLength:13 key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
    
    
}

+(void)v2_aes_calibation_time_with_version:(NSString*)version  
                                      referenceTime:(NSString *)referenceTime
                                                key:(Byte*)pwdkey  {

   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];

    //[command commandWithVersion:version];
    
    Byte values[5]={
        0x00,0x00,0x00,0x00,0x00
    };
    
    NSArray * timeArray = [referenceTime componentsSeparatedByString:@"-"];
    for (int i = 0 ; i < timeArray.count ; i ++) {
        
        int number = ((NSString *)timeArray[i]).intValue;
        
        NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",number]];
        
        Byte *numberByte = (Byte *)[numberData bytes];
        values[i] = numberByte[0];
        
    }
    
    [command setCommand:COMM_LOCK_TIME_CALIBRATION];
    
    [command setDataAES:values withLength:5 key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
    
    

}

// unlock  --flag(’0x00’,无操作;’0x01’, 设置无钥匙密码;’0x02’,校准时钟;'0x03',同步当前有效密码序列)
// psCurrent当前有效密码序列组
+(void)v2_aes_unlock_with_psFromLock:(long long)psFromLock
                         psLocal:(long long)psLocal
                            flag:(NSString*)flag
                version:(NSString*)version
                             key:(Byte*)pwdkey 
{
    
   
    
    NSString *sum = [self getUnlockPassword:psFromLock localPassword:psLocal];
   TTCommand *command = [[TTCommand alloc]init];
    //[command commandWithVersion:version];
    [command commandWithVersion:version];
    Byte values[5]={
        0x00,0x00,0x00,0x00,0x00
    };
    
    long long psNumber = sum.longLongValue;
    NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%08llx",psNumber]];
    Byte *psByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:0 length:4];
    
    NSData *unlocknumberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",flag.intValue]];
    Byte *unlockByte = (Byte *)[unlocknumberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:unlockByte  srcPos:0 dst:values dstPos:4 length:1];
    
    [command setCommand:COMM_LOCK_UNLOCK];
    
    [command setDataAES:values withLength:5 key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
    
    
}

+(void)v2_aes_init_ps_pool_bytes:(Byte*)bytes
                          length:(int)length
                             pos:(int)pos
                version:(NSString*)version
                             key:(Byte*)pwdkey
                     

{


   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    Byte values[30] = {
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00
    };
    
    
    [TTDataTransformUtil arrayCopyWithSrc:bytes  srcPos:0 dst:values dstPos:0 length:length];
    
    
    NSData * data = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",pos]];
    Byte * dataByte = (Byte *)data.bytes;
    
    if (data.length == 1) {
        
        values[28] = dataByte[0];
        
    }else if (data.length == 2) {
        
        values[28] = dataByte[1];
        values[29] = dataByte[0];
        
    }
    
    [command setCommand:COMM_LOCK_INIT_PS];
    
    //    [command setData:values withLength:32];
    [command setDataAES:values withLength:30 key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
  
}

+(void)v2_aes_del_kbpwd:(NSString*)passwrod
       version:(NSString*)version
                    key:(Byte*)pwdkey
             {
   
   
    
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    Byte values[10]={
        0xFF,0xFF,0xFF,0xFF,0xFF,
        0xFF,0xFF,0xFF,0xFF,0xFF
    };
    
    //    NSData *psData = [password dataUsingEncoding: NSUTF8StringEncoding];
    //    Byte *psByte = (Byte *)[psData bytes];
    
    Byte psByte[passwrod.length];
    for (int i = 0 ; i < passwrod.length; i ++) {
        
        NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",[passwrod characterAtIndex:i]-'0']];
        
        Byte *numberByte = (Byte *)[numberData bytes];
        psByte[i] = numberByte[0];
        
    }
    
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:0 length:passwrod.length];
    
    [command setCommand:V2_AES_COMM_LOCK_SET_ADMIN_DEL_PS];
    
    //    [command setData:values withLength:10];
    [command setDataAES:values withLength:10 key:pwdkey];
    
   [self readyToWriteValueWithComand:command];

}

+(void)park_lock_v1_check_user_startDate:(NSString*)startDate endDate:(NSString*)endDate {
    
  
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[10]={
        0x0,0x0,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0
    };
    
    // start date
    {
        
        NSArray * timeArray = [startDate componentsSeparatedByString:@"-"];
        for (int i = 0 ; i < timeArray.count ; i ++) {
            
            int unlockNumber = ((NSString *)timeArray[i]).intValue;
            
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",unlockNumber]];
            
            Byte *numberByte = (Byte *)[numberData bytes];
            
            values[i] = numberByte[0];
            
        }
        
    }
    
    // end date
    {
        
        NSArray * timeArray = [endDate componentsSeparatedByString:@"-"];
        for (int i = 0 ; i < timeArray.count ; i ++) {
            
            int unlockNumber = ((NSString *)timeArray[i]).intValue;
            
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",unlockNumber]];
            
            Byte *numberByte = (Byte *)[numberData bytes];
            
            values[5+i] = numberByte[0];
            
        }
        
    }
    
    [command setCommand:PARK_LOCK_V1_COMM_CHECK_USER_TIME];
    
    [command setData:values withLength:10];
    
   [self readyToWriteValueWithComand:command];
    
}

+(void)park_lock_v1_calibation_timeWithReferenceTime:(NSString *)referenceTime {
  

   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[5]={
        0x0,0x0,0x0,0x0,0x0
    };
    
    {
        
        NSArray * timeArray = [referenceTime componentsSeparatedByString:@"-"];
        for (int i = 0 ; i < timeArray.count ; i ++) {
            
            int unlockNumber = ((NSString *)timeArray[i]).intValue;
            
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",unlockNumber]];
            
            Byte *numberByte = (Byte *)[numberData bytes];
            values[i] = numberByte[0];
            
        }
        
    }
    
    //    NSData *psData = [time dataUsingEncoding: NSUTF8StringEncoding];
    //    Byte *psByte = (Byte *)[psData bytes];
    //    [MyUtils arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:0 length:time.length];
    
    [command setCommand:PARK_LOCK_V1_COMM_TIME_CALIBRATION];
    
    [command setData:values withLength:5];
    
   [self readyToWriteValueWithComand:command];
}

+(void)park_lock_v1_unlock_psFromLock:(long long)psFromLock psLocal:(long long)psLocal flag:(NSString*)flag  {
    
    NSString *sum = [self getParkUnlockPassword:psFromLock localPassword:psLocal];

      TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[12]={   0x0,0x0,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0,
        0x0,0x0
    };
    
    NSData *psData = [sum dataUsingEncoding: NSUTF8StringEncoding];
    Byte *psByte = (Byte *)[psData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:0 length:sum.length];
    
    values[10] = 0x20;
    
    NSData *numberData = [flag dataUsingEncoding: NSUTF8StringEncoding];
    Byte *numberByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:numberByte  srcPos:0 dst:values dstPos:11 length:flag.length];
    
    [command setCommand:PARK_LOCK_V1_COMM_UNLOCK];
    
    [command setData:values withLength:12];
    
    
   [self readyToWriteValueWithComand:command];
}

+(void)park_lock_v1_lock_psFromLock:(long long)psFromLock psLocal:(long long)psLocal flag:(NSString *)flag {
    
    
    NSString *sum = [self getParkUnlockPassword:psFromLock localPassword:psLocal];
 
    
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[12]={   0x0,0x0,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0,
        0x0,0x0
    };
    
    NSData *psData = [sum dataUsingEncoding: NSUTF8StringEncoding];
    Byte *psByte = (Byte *)[psData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:0 length:sum.length];
    
    values[10] = 0x20;
    
    NSData *numberData = [flag dataUsingEncoding: NSUTF8StringEncoding];
    Byte *numberByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:numberByte  srcPos:0 dst:values dstPos:11 length:flag.length];
    
    [command setCommand:PARK_LOCK_V1_COMM_LOCK];
    
    
    [command setData:values withLength:12];
    
    [self readyToWriteValueWithComand:command];    
}


+(void)park_lock_v1_check_admin_with_ps:(NSString*)password {

    
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[10]={   0x0,0x0,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0};
    
    NSData *psData = [password dataUsingEncoding: NSUTF8StringEncoding];
    Byte *psByte = (Byte *)[psData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:0 length:password.length];
    
    [command setCommand:PARK_LOCK_V1_COMM_CHECK_ADMIN];
    
    [command setData:values withLength:10];
    
   [self readyToWriteValueWithComand:command];
}

+(void)park_lock_v1_add_admin_with_ps:(NSString*)password number:(NSString*)unlocknumber {

   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[21]={
        0x0,0x0,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0,
        0x0};
    
    NSData *psData = [password dataUsingEncoding: NSUTF8StringEncoding];
    Byte *psByte = (Byte *)[psData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:values dstPos:0 length:10];
    
    values[10] = 0x20;
    
    NSData *numberData = [unlocknumber dataUsingEncoding: NSUTF8StringEncoding];
    Byte *numberByte = (Byte *)[numberData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:numberByte  srcPos:0 dst:values dstPos:11 length:10];
    
    [command setCommand:PARK_LOCK_V1_COMM_ADD_ADMIN];
    
    [command setData:values withLength:21];
    
   [self readyToWriteValueWithComand:command];
}

+(void)park_lock_v1_reset_lockWith{

    
   TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:nil];
    
    Byte values[0];
    
    [command setCommand:PARK_LOCK_V1_COMM_RESET];
    
    [command setData:values withLength:0];
    
   [self readyToWriteValueWithComand:command];
}

+(void)park_lock_v1_get_lock_stateWith{
   TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:nil];
    
    Byte values[0];
    
    [command setCommand:PARK_LOCK_V1_COMM_GET_STATE];
    
    [command setData:values withLength:0];

   [self readyToWriteValueWithComand:command];
}

+(void)park_lock_v1_rename:(Byte*)nameBytes length:(NSUInteger)length {
    
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:nil];
    Byte values[length];
    
    [TTDataTransformUtil arrayCopyWithSrc:nameBytes  srcPos:0 dst:values dstPos:0 length:length];
    
    
    [command setCommand:PARK_LOCK_V1_COMM_RENAME];
    
    [command setData:values withLength:length];
    
    [self readyToWriteValueWithComand:command];
}

+(void)park_lock_v1_warn_recordWith{
  
    
   TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:nil];
    
    Byte values[0];
    
    [command setCommand:PARK_LOCK_V1_COMM_WARN_RECORD];
    
    [command setData:values withLength:0];
    
   [self readyToWriteValueWithComand:command];
}


//读取开锁记录  type 1 读取操作记录  2 读取IC卡记录 //3 读取指纹记录 4 开锁密码
+(void)lock_fetch_record_num:(int)num
                        type:(int)type
                     version:(NSString*)version
                         key:(Byte*)pwdkey
{
    
  
   TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
    NSInteger dataLen = 0 ;
    Byte datas[3];
    if (type==1) {
        dataLen = 2;
        NSData *oprationData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",num]];
        Byte *oprByte = (Byte *)[oprationData bytes];
        [TTDataTransformUtil arrayCopyWithSrc:oprByte  srcPos:0 dst:datas dstPos:0 length:dataLen];
        [command setCommand:LOCK_V4_COMM_READ_LOCKRECORD];
    } 
     if(type == 2){
        dataLen = 3;
        datas[0] = 0x01;
        NSData *oprationData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",num]];
        Byte *oprByte = (Byte *)[oprationData bytes];
        [TTDataTransformUtil arrayCopyWithSrc:oprByte  srcPos:0 dst:datas dstPos:1 length:2];
        [command setCommand:Lock_V3_COMM_IC_Manager];
    }
    if (type == 3){
        dataLen = 3;
        //指纹的查询类型是 6
        datas[0] = 0x06;
        NSData *oprationData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",num]];
        Byte *oprByte = (Byte *)[oprationData bytes];
        [TTDataTransformUtil arrayCopyWithSrc:oprByte  srcPos:0 dst:datas dstPos:1 length:2];
        [command setCommand:Lock_V3_COMM_Fingerprint_Manager];
    }
    if (type == 4) {
        dataLen = 2;
        NSData *oprationData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",num]];
        Byte *oprByte = (Byte *)[oprationData bytes];
        [TTDataTransformUtil arrayCopyWithSrc:oprByte  srcPos:0 dst:datas dstPos:0 length:dataLen];
        [command setCommand:COMM_FETCH_USER_PS_LIST];
    }
    
    [command setDataAES:datas withLength:(int)dataLen key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
    
}

//添加单次键盘密码
+(void)add_onepassword_oprationType:(int)oprationType
                             limitType:(TTPasscodeType)limitType
                              password:(NSString*)password
                             startDate:(NSString*)startDate
                               endDate:(NSString*)endDate
                      version:(NSString*)version
                               key:(Byte*)pwdkey
                           
{

   TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
    NSInteger dataLen = 1 + 1 + 1 + password.length ;
    
    //limitType 密码类型是跟服务端统一  锁里 1是永久 2 单次 3时限
    int lockLimitType;
    
    switch (limitType) {
        case TTPasscodeTypePermanent:{
            dataLen = dataLen + 5;
            lockLimitType = 1;
        }break;
        case TTPasscodeTypeOnce:{
            dataLen = dataLen + 5;
            lockLimitType = 2;
        } break;
        case TTPasscodeTypePeriod:{
            dataLen = dataLen + 10;
            lockLimitType = 3;
        }
        default:
            break;
    }
    
    Byte datas[dataLen];
    
    //操作类型 1字节
    NSData *oprationTypeData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",oprationType]];
    Byte *oprByte = (Byte *)[oprationTypeData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:oprByte  srcPos:0 dst:datas dstPos:0 length:1];
    
    //密码类型 1字节
    
    NSData *limitTypeData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",lockLimitType]];
    Byte *limitTypeByte = (Byte *)[limitTypeData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:limitTypeByte  srcPos:0 dst:datas dstPos:1 length:1];
    
    //密码长度 1字节
    NSData *pswLengthData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",(int)password.length]];
    Byte *lengthByte = (Byte *)[pswLengthData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:lengthByte  srcPos:0 dst:datas dstPos:2 length:1];
    
    //密码 n个字节(password.length个字节)
    
    NSData *psData = [password dataUsingEncoding: NSUTF8StringEncoding];
    Byte *psByte = (Byte *)[psData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:datas dstPos:3 length:password.length];
   
    switch (limitType) {
        case TTPasscodeTypePermanent:
        case TTPasscodeTypeOnce:
        {
    
            NSString *timeStr =startDate;
            NSArray * timeArray = [timeStr componentsSeparatedByString:@"-"];//@"yy-MM-dd-HH-mm"
            for (int i = 0 ; i < timeArray.count ; i ++) {
                
                int number = ((NSString *)timeArray[i]).intValue;

                NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",number]];
                
                Byte *numberByte = (Byte *)[numberData bytes];
                datas[i+3+password.length] = numberByte[0];
            }
        }break;
            
        case TTPasscodeTypePeriod:
              {
                 //时间
                NSString *timeStr = [NSString stringWithFormat:@"%@-%@",startDate,endDate];
                  NSArray * timeArray = [timeStr componentsSeparatedByString:@"-"];//@"yy-MM-dd-HH-mm"
                  for (int i = 0 ; i < timeArray.count ; i ++) {
                      
                      int number = ((NSString *)timeArray[i]).intValue;
                 
                      NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",number]];
                      
                      Byte *numberByte = (Byte *)[numberData bytes];
                      datas[i+3+password.length] = numberByte[0];
                  }

        }break;
        default:
            break;
    }
        
    [command setCommand:COMM_USER_PS_SET_DEL];
    
    
    [command setDataAES:datas withLength:(int)dataLen key:pwdkey];
    
   [self readyToWriteValueWithComand:command];

}

//删除单个键盘密码
+(void)delete_onepassword_oprationType:(int)oprationType
                                limitType:(int)limitType
                                 password:(NSString*)password
                         version:(NSString*)version  
                                      key:(Byte*)pwdkey
                             
{
    
   TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
   
    NSInteger dataLen = 1 + 1 + 1 + password.length ;
    Byte datas[dataLen];
    
    //操作类型 1字节
    NSData *oprationTypeData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",oprationType]];
    Byte *oprByte = (Byte *)[oprationTypeData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:oprByte  srcPos:0 dst:datas dstPos:0 length:1];
    
    //密码类型 1字节
    NSData *limitTypeData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",limitType]];
    Byte *limitTypeByte = (Byte *)[limitTypeData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:limitTypeByte  srcPos:0 dst:datas dstPos:1 length:1];
    
    //密码长度 1字节
    NSData *pswLengthData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",(int)password.length]];
    Byte *lengthByte = (Byte *)[pswLengthData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:lengthByte  srcPos:0 dst:datas dstPos:2 length:1];
    
    //密码 n个字节(password.length个字节)
    NSData *psData = [password dataUsingEncoding: NSUTF8StringEncoding];
    Byte *psByte = (Byte *)[psData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:datas dstPos:3 length:password.length];
    
    [command setCommand:COMM_USER_PS_SET_DEL];
    
    [command setDataAES:datas withLength:(int)dataLen key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
    
}
//清空键盘密码
+(void)clear_allpassword_oprationType:(int)oprationType
                                adminPwd:(NSString*)adminPwd
                        version:(NSString*)version
                                     key:(Byte*)pwdkey
                             
{
    
    
   TTCommand *command = [[TTCommand alloc]init];
    
    [command commandWithVersion:version];
    
    
    NSInteger dataLen = 1+ 1 + 1 ;//+ adminPwd.length
    Byte datas[dataLen];
    
    //操作类型 1字节
    datas[0] = oprationType;
    
    //补两个0
    datas[1] = 0;
    datas[2] = 0;
  
    
    
    [command setCommand:COMM_USER_PS_SET_DEL];
    
    [command setDataAES:datas withLength:(int)dataLen key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
    
}
//设备参数设置/查询
+ (void)setOrQuery_Para:(NSString*)para
          version:(NSString*)version  
                       key:(Byte*)pwdkey
             {
    
    
   TTCommand *command = [[TTCommand alloc]init];
    [command commandWithVersion:version];
    
    NSInteger dataLen = para.length ;//+ 2
    Byte datas[dataLen];
    
    NSData *paraData = [para dataUsingEncoding:NSUTF8StringEncoding];
    Byte *paraByte = (Byte*)[paraData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:paraByte srcPos:0 dst:datas dstPos:0 length:para.length];
//    
//    // \r
//    datas[para.length] = 0x0D;
//    // \n
//    datas[para.length+1] = 0x0A;
    
    [command setCommand:COMM_LOCK_Device_Parameter_Settings];
    
    [command setDataAES:datas withLength:(int)dataLen key:pwdkey];
    
    [self readyToWriteValueWithComand:command];
    
}
//***************要写进锁里数据准备完整*****************
+ (void)readyToWriteValueWithComand:(TTCommand*)command{
    
    int len = 2 + 1 + 1 + 1 +2 + 2 + 1 + 1 + 1 + command->length + 1;
    Byte commandWithoutChecksum[len];
    [command buildCommand:commandWithoutChecksum withLength:len];
    Byte bytesWithEndChar[len+2];
    [TTDataTransformUtil arrayCopyWithSrc:commandWithoutChecksum srcPos:0 dst:bytesWithEndChar dstPos:0 length:len];
    bytesWithEndChar[len] = 13;
    bytesWithEndChar[len+1]=10;
    
    [self writeValueWithData:[NSData dataWithBytes:bytesWithEndChar length:len+2]];
}
//***************发送数据需要用的东西******************
+(void)writeValueWithData:(NSData *)data {
    
    CBPeripheral *p =  [[TTCenterManager sharedInstance] activePeripheral];
    
    UInt16 s = [self swap:fileService];
    UInt16 c = [self swap:fileSubWrite];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUIDEx:su p:p];
    
    
    if (!service) {
    
        printf("TTLockLog#####Please connect the lock first#####\n");
        
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUIDEx:cu service:service];
    if (!characteristic) {
        printf("TTLockLog#####Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s#####",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef)(p.identifier)]);
        return;
    }
    
    
    Byte bytes[data.length];
    [data getBytes:bytes];
    
    {
        int datalength = (int) data.length;
        int cut = datalength/20;
        if (cut >= 1) {
            
        }
        
        Byte* bytes = (Byte *)data.bytes;
        
        for (int i = 0; i <= cut; i++) {
            
            int singleDatalen = 20;
            if (i == cut) {
                
                singleDatalen = datalength - i*20;
            }
            Byte byte20[singleDatalen];
            [TTDataTransformUtil arrayCopyWithSrc:bytes srcPos:i*20 dst:byte20 dstPos:0 length:singleDatalen];
            
            [p writeValue:[NSData dataWithBytes:byte20 length:singleDatalen] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
  
        }
        
    }
}



/*
 *  @method findCharacteristicFromUUID:
 *
 *  @param UUID CBUUID to find in Characteristic list of service
 *  @param service Pointer to CBService to search for charateristics on
 *
 *  @return pointer to CBCharacteristic if found, nil if not
 *
 *  @discussion findCharacteristicFromUUID searches through the characteristic list of a given service
 *  to find a characteristic with a specific UUID
 *
 */
+(CBCharacteristic *) findCharacteristicFromUUIDEx:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}


/*
 *  @method UUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion UUIDToString converts the data of a CFUUIDRef class to a character pointer for easy printout using
 *
 */
+(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);
    
}

/*
 *  @method CBUUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion CBUUIDToString converts the data of a CBUUID class to a character pointer for easy printout using
 *
 */
+(const char *) CBUUIDToString:(CBUUID *) UUID {
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}

/*
 *  @method findServiceFromUUID:
 *
 *  @param UUID CBUUID to find in service list
 *  @param p Peripheral to find service on
 *
 *  @return pointer to CBService if found, nil if not
 *
 *  @discussion findServiceFromUUID searches through the services list of a peripheral to find a
 *  service with a specific UUID
 *
 */
+(CBService *) findServiceFromUUIDEx:(CBUUID *)UUID p:(CBPeripheral *)p {
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}

/*
 *  @method compareCBUUID
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUID compares two CBUUID's to each other and returns 1 if they are equal and 0 if they are not
 *
 */

+(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}

/*!
 *  @method swap:
 *
 *  @param s Uint16 value to byteswap
 *
 *  @discussion swap byteswaps a UInt16
 *
 *  @return Byteswapped UInt16
 */

+(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

+ (void)writeDataToBongWithKey:(NSString*)key
                        isOpen:(BOOL)isOpen
                             p:(CBPeripheral *)peripheral{

    CBService *service = peripheral.services[0];
    CBCharacteristic *characteristic;
    if (!service) {
        printf("TTLockLog#####Please connect the lock first#####\n");
        return;
    }
    
    for(int i = 0; i < service.characteristics.count; i++){
        if ([TTDataTransformUtil isString:[NSString stringWithFormat:@"%s",[self CBUUIDToString:service.characteristics[i].UUID]] contain:bongFileSubWriteString]) {
            characteristic = service.characteristics[i];
        }
    }
    if (!characteristic) {
        printf("TTLockLog#####Could not find characteristic on service on peripheral with UUID %s#####",[self UUIDToString:(__bridge CFUUIDRef)(peripheral.identifier)]);
        return;
    }
    
    if (isOpen) {
        Byte bytes[12];
        bytes[0]=0x31;
        bytes[1]=0x00;
        bytes[2]=0x00;
        bytes[3]=0x00;
        bytes[4]=0x01;
        bytes[5]=0x01;
        NSData *psData = [key dataUsingEncoding: NSUTF8StringEncoding];
        Byte *psByte = (Byte *)[psData bytes];
        [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:bytes dstPos:6 length:key.length];
         [peripheral writeValue:[NSData dataWithBytes:bytes length:12] forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }else{
         Byte bytes[6];
        bytes[0]=0x31;
        bytes[1]=0x00;
        bytes[2]=0x00;
        bytes[3]=0x00;
        bytes[4]=0x01;
        bytes[5]=0x00;
        
         [peripheral writeValue:[NSData dataWithBytes:bytes length:6] forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];//
    }

}
+ (void)writeDataToBongRssi:(int )rssi
                        p:(CBPeripheral *)peripheral{
    
    CBService *service = peripheral.services[0];
    CBCharacteristic *characteristic;
    if (!service) {
        printf("TTLockLog#####Please connect the lock first#####\n");
        return;
    }
    
    for(int i = 0; i < service.characteristics.count; i++){
        if ([TTDataTransformUtil isString:[NSString stringWithFormat:@"%s",[self CBUUIDToString:service.characteristics[i].UUID]] contain:bongFileSubWriteString]) {
            characteristic = service.characteristics[i];
        }
    }
    if (!characteristic) {
        printf("TTLockLog#####Could not find characteristic on service on peripheral with UUID %s#####",[self UUIDToString:(__bridge CFUUIDRef)(peripheral.identifier)]);
        return;
    }
    Byte bytes[6];
    bytes[0]=0x31;
    bytes[1]=0x00;
    bytes[2]=0x00;
    bytes[3]=0x00;
    bytes[4]=0x02;
    NSData * rssidata =  [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%x",rssi]];
    Byte *rssidataByte = (Byte *)[rssidata bytes];
    bytes[5] = rssidataByte[0];
    
        [peripheral writeValue:[NSData dataWithBytes:bytes length:6] forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];//
  
    
}
@end
