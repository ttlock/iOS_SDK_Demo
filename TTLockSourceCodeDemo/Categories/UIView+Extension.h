//
//  UIView+Extension.h
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/19.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface UIView (Extension)


#pragma mark - HUD

- (void)showToastLoading;
- (void)showToastLoading:(NSString *)text;

- (void)showToast:(NSString *)text;
- (void)showToast:(NSString *)text completion:(void (^)(void))block;

- (void)showToastError:(id)info;
- (void)showToastError:(id)info completion:(void (^)(void))block;

- (MBProgressHUD *)showProgress:(NSString *)text;

- (void )hideToast;

@end
