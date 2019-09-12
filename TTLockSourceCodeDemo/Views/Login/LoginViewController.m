//
//  LoginViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/19.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "LoginViewController.h"
#import <Masonry/Masonry.h>
#import "IQKeyboardManager.h"
#import "NetUtil.h"
#import "UserModel.h"
#import "AppDelegate.h"
#import "NSString+Extension.h"

@interface LoginViewController ()
@property (nonatomic, weak) UITextField *usernameTextField;
@property (nonatomic, weak) UITextField *passcodeTextField;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    
    [self setupView];
}

- (void)loginClick{
    NSString *username = _usernameTextField.text;
    NSString *password = _passcodeTextField.text;
    if (username.length == 0 || password.length == 0) return;
    
    [self.view showToastLoading];
    [NetUtil loginUsername:username password:[password md5Encode] completion:^(NSDictionary *info, NSError *error) {
        if (error){
            [self.view showToastError:error];
            return ;
        }
        [self.view hideToast];
        
        UserModel *userModel = [UserModel new];
        userModel.username = username;
        userModel.uid = info[@"uid"];
        userModel.accessToken = info[@"access_token"];
        [userModel cacheToDisk];
        
        AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
        [appDelegate showHomeViewController];
    }];
}

- (void)registerClick{
    [self.view showToast:LS(@"Go to register a account from app TTLock") completion:^{
        NSString *urlStr = @"https://apps.apple.com/cn/app/id1033046018";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }];
}

- (void)setupView{
    _usernameTextField = [self setupTextFieldViewWithPlaceholder:LS(@"Please input username")];
    _passcodeTextField = [self setupTextFieldViewWithPlaceholder:LS(@"Please input password")];
    
    UILabel *usernameLabel = [self setupLabelWithText:LS(@"Username")];
    UILabel *passcodeLabel = [self setupLabelWithText:LS(@"Password")];
    
    UIButton *loginButton = [UIButton new];
    [loginButton setTitle:LS(@"Sign in") forState:UIControlStateNormal];
    [loginButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    loginButton.layer.cornerRadius = 4;
    loginButton.layer.masksToBounds = YES;
    loginButton.layer.borderWidth = 1;
    loginButton.layer.borderColor = UIColor.blackColor.CGColor;
    [loginButton addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    UIButton *registerButton = [UIButton new];
    [registerButton setTitle:LS(@"Sign up") forState:UIControlStateNormal];
    [registerButton setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerButton];
    
    [_usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(25);
        make.top.mas_equalTo(120);
        make.height.mas_equalTo(50);
    }];
    [usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.usernameTextField);
        make.bottom.equalTo(self.usernameTextField.mas_top);
        make.height.mas_equalTo(20);
    }];
    [_passcodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.usernameTextField);
        make.top.equalTo(self.usernameTextField.mas_bottom).offset(40);
    }];
    [passcodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(usernameLabel);
        make.bottom.equalTo(self.passcodeTextField.mas_top);
    }];
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.usernameTextField);
        make.top.equalTo(self.passcodeTextField.mas_bottom).offset(65);
    }];
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(loginButton);
        make.top.equalTo(loginButton.mas_bottom).offset(15);
    }];
}

- (UILabel *)setupLabelWithText:(NSString *)text{
    UILabel *label = [UILabel new];
    label.textColor = UIColor.darkGrayColor;
    label.text = text;
    [self.view addSubview:label];
    return label;
}

- (UITextField *)setupTextFieldViewWithPlaceholder:(NSString *)placeholder{
    UITextField *textField = [UITextField new];
    textField.tintColor = UIColor.blackColor;
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.placeholder = placeholder;
    [self.view addSubview:textField];
    
    UIView *line = [UIView new];
    line.backgroundColor = UIColor.blackColor;
    line.alpha = 0.5;
    [textField addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(textField);
        make.height.mas_equalTo(1);
    }];
    
    return textField;
}




@end
