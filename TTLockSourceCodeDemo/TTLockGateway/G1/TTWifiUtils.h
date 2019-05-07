//
// 
//  BTstackCocoa
//
//  Created by wan on 13-1-31.
//
//

#import <Foundation/Foundation.h>

@interface TTWifiUtils : NSObject

+(NSData*)DataFromHexStr:(NSString *)hexString;

+(void) arrayCopyWithSrc:(Byte*)src srcPos:(int)srcPos dst:(Byte*)dst dstPos:(NSUInteger)dstPos length:(NSUInteger)length;
@end
