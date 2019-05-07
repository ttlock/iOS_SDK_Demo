//
//  TTButton.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/26.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "RoundCornerButton.h"

@implementation RoundCornerButton
+ (RoundCornerButton *)buttonWithTitle:(NSString *)title cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth{
    RoundCornerButton *button = [RoundCornerButton new];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button.layer.cornerRadius = cornerRadius;
    button.layer.masksToBounds = YES;
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = borderWidth;
    return button;
}

@end
