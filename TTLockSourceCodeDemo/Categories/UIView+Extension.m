//
//  UIView+Extension.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/19.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "UIView+Extension.h"

#define kHudDuration 2

@implementation UIView (Extension)

- (MBProgressHUD *)showHudMode:(MBProgressHUDMode)mode{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self];
    if (hud == nil) {
        [self hideToast];
        hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    }
    
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.color = RGB_A(0, 0, 0, 1);
    hud.label.numberOfLines = 0;
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = mode;
    return hud;
}

- (void)showToastLoading{
    [self showToastLoading:nil];
}

- (void)showToastLoading:(NSString *)text{
    MBProgressHUD *lastHud = [MBProgressHUD HUDForView:self];
    if (lastHud && ([text isEqualToString:lastHud.label.text] || (text.length == 0 && lastHud.label.text.length == 0))) {
        return;
    }
    MBProgressHUD *hud = [self showHudMode:MBProgressHUDModeIndeterminate];
    hud.label.text = text;
}

- (void)showToast:(NSString *)text{
    [self showToast:text completion:nil];
}

- (void)showToast:(NSString *)text completion:(void (^)(void))block{
    MBProgressHUD *hud = [self showHudMode:MBProgressHUDModeText];
    hud.label.text = text;
    CGFloat duration = text.length > 10 ? kHudDuration * 2 : kHudDuration;
    [hud hideAnimated:YES afterDelay:duration];
    [self performSelector:@selector(pt_hideHUD:) withObject:block afterDelay:duration];
}

- (void)showToastSuccess:(NSString *)text{
    
    [self showToastSuccess:text completion:nil];
}

- (void)showToastSuccess:(NSString *)text completion:(void (^)(void))block{
    MBProgressHUD *hud = [self showHudMode:MBProgressHUDModeText];
    hud.label.text = text;
    hud.bezelView.color = RGBFromHexadecimal(0xe6f3e1);
    hud.offset = CGPointMake(0,  (- self.frame.size.height / 2) + 20);
    [hud hideAnimated:YES afterDelay:kHudDuration];
    CGFloat duration = text.length > 10 ? kHudDuration * 2 : kHudDuration;
    [self performSelector:@selector(pt_hideHUD:) withObject:block afterDelay:duration];
}

- (void)showToastError:(id)info completion:(void (^)(void))block{
    MBProgressHUD *hud = [self showHudMode:MBProgressHUDModeCustomView];
    UIImage *image = [UIImage imageNamed:@"hudError"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    hud.customView = imageView;
    
    NSString *text = @"";
    if ([info isKindOfClass:[NSError class]]) {
        NSError *error = (NSError *)info;
        text = error.userInfo[NSLocalizedDescriptionKey];
    }else if ([info isKindOfClass:[NSString class]]){
        text = info;
    }
    hud.label.text = text;
    [hud hideAnimated:YES afterDelay:kHudDuration];
    [self performSelector:@selector(pt_hideHUD:) withObject:block afterDelay:kHudDuration];
}

- (void)showToastError:(id)info{
    [self showToastError:info completion:nil];
}


- (MBProgressHUD *)showProgress:(NSString *)text{
    [self hideToast];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:NO];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.label.text = text ?: @"";
    return hud;
}

-(void)pt_hideHUD:(void (^)(void))block{
    if (block) block();
}

- (void )hideToast{
    [MBProgressHUD hideHUDForView:[[[UIApplication sharedApplication] delegate] window] animated:NO];
    [MBProgressHUD hideHUDForView:self animated:NO];
}
@end
