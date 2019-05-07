//
//  KJXIAChooseSSIDView.h
//  Sciener
//
//  Created by 王娟娟 on 2019/3/11.
//  Copyright © 2019 sciener. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseSSIDView : UIView

@property (nonatomic,strong)NSArray *ssidArr;
@property (nonatomic,strong)UITableView *ssidTableView;

@property (nonatomic,strong)UIActivityIndicatorView *testActivityIndicator;

@property (nonatomic,copy) void (^chooseSSIDBlock)(NSString * SSID);

- (void)dismiss;

@end

