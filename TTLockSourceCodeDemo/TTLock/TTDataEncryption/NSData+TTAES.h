//
//  NSData+AES.h
//  Smile
//
//  Created by 周 敏 on 12-11-24.
//  Copyright (c) 2012年 BOX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSString;

@interface NSData (Encryption)

- (NSData *)AES256EncryptWithKeyBytes:(Byte *)keyPtr gIv:(Byte * )ivPtr;    //加密bytes
- (NSData *)AES256DecryptWithKeyBytes:(Byte *)key gIv:(Byte * )gIv;   //解密bytes

- (NSData *)AES256EncryptWithKey:(NSString *)key gIv:(NSString * )gIv;   //加密
- (NSData *)AES256DecryptWithKey:(NSString *)key gIv:(NSString * )gIv;   //解密

@end
