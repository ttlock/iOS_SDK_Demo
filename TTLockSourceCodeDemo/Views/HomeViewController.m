//
//  RootViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/26.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "HomeViewController.h"
#import "LockTableViewController.h"
#import "GatewayTableViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}


- (void)setupView{
    self.title = @"TTLock demo";
    
    UIButton *lockButton = [self setupButtonTitle:LS(@"Lock") selector:@selector(lockButtonClick:)];
    UIButton *gatewayButton = [self setupButtonTitle:LS(@"Gateway") selector:@selector(gatewayButtonClick:)];
    
    [lockButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(40);
        make.height.mas_equalTo(self.view.frame.size.height/4);
        make.bottom.equalTo(self.view.mas_centerY).offset(- 20);
    }];
    
    [gatewayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.left.equalTo(lockButton);
        make.top.equalTo(self.view.mas_centerY).inset(20);
    }];
}


- (void)gatewayButtonClick:(UIButton *)button{
    GatewayTableViewController *vc = [GatewayTableViewController new];
    vc.title = button.titleLabel.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)lockButtonClick:(UIButton *)button{
    LockTableViewController *vc = [LockTableViewController new];
    vc.title = button.titleLabel.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIButton *)setupButtonTitle:(NSString *)title selector:(SEL)selector{
    UIButton *button = [UIButton new];
    button.titleLabel.font = [UIFont systemFontOfSize:35];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button.layer.cornerRadius = 6;
    button.layer.masksToBounds = YES;
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.layer.borderWidth = 0.5;
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    return button;
}


@end
