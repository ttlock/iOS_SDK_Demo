//
//  Utils.m
//  BTstackCocoa
//
//  Created by wan on 13-1-31.
//
//

#import "TTMacros.h"

@implementation TTMacros

NSString * const  TTErrorMessageBluetoothPoweredOff = @"Bluetooth is currently powered off";
NSString * const  TTErrorMessageConnectionTimeout = @"Device and lock connected timeout";
NSString * const  TTErrorMessageDisconnection = @"Bluetooth connection has been disconnected";
NSString * const  TTErrorMessageLockIsBusy = @"only one lock can work with Device at a time";
NSString * const  TTErrorMessageHadReseted = @"The lock may have been reset";
NSString * const  TTErrorMessageCRCError = @"CRC check error,you can try again";
NSString * const  TTErrorMessageNoPermisstion = @"Failure of identity verification and no operation permissions";
NSString * const  TTErrorMessageWrongAdminCode = @"Admin code is wrong";
NSString * const  TTErrorMessageLackOfStorageSpace = @"Lack of storage space";
NSString * const  TTErrorMessageInSettingMode = @"In setting mode";
NSString * const  TTErrorMessageNoAdmin = @"No administrator";
NSString * const  TTErrorMessageNotInSettingMode = @"Not in setting mode";
NSString * const  TTErrorMessageWrongDynamicCode = @"Dynamic code is error";
NSString * const  TTErrorMessageIsNoPower = @"The lock is out of power";
NSString * const  TTErrorMessageResetPasscode = @"Reset 900 passcodes failed";
NSString * const  TTErrorMessageUpdatePasscodeIndex = @"Update the keyboard passcode sequence error";
NSString * const  TTErrorMessageInvalidLockFlagPos = @"Invalid lockFlagPos";
NSString * const  TTErrorMessageEkeyExpired = @"ekey has expired";
NSString * const  TTErrorMessagePasscodeLengthInvalid = @"Invalid passcode length";
NSString * const  TTErrorMessageSamePasscodes = @"Admin Passcode is the same as Erase Passcode";
NSString * const  TTErrorMessageEkeyInactive = @"ekey is Inactive";
NSString * const  TTErrorMessageAesKey = @"No login, no operation permissions";
NSString * const  TTErrorMessageFail = @"operation failed";
NSString * const  TTErrorMessagePasscodeExist = @"The added passcode has already existed";
NSString * const  TTErrorMessagePasscodeNotExist = @"The passcode that are deleted or modified does not exist";
NSString * const  TTErrorMessageLackOfStorageSpaceWhenAddingPasscodes = @"Lack of storage space (as when adding a passcode)";
NSString * const  TTErrorMessageInvalidParaLength = @"Invalid parameter length";
NSString * const  TTErrorMessageCardNotExist = @"IC card does not exist";
NSString * const  TTErrorMessageFingerprintDuplication = @"Duplication of fingerprints";
NSString * const  TTErrorMessageFingerprintNotExist = @"Fingerprints do not exist";
NSString * const  TTErrorMessageInvalidCommand = @"This feature is not supported";
NSString * const  TTErrorMessageInFreezeMode = @"In Freeze Mode";
NSString * const  TTErrorMessageInvalidClientPara = @"Invalid special string";
NSString * const  TTErrorMessageLockIsLocked = @"Lock is locked";
NSString * const  TTErrorMessageRecordNotExist = @"Record do not exist";
NSString * const  TTErrorMessageNotSupportModifyPasscode = @"Not support the modification of the passcode";
NSString * const  TTErrorMessageWrongLockData = @"lockData is wrong";


@end
