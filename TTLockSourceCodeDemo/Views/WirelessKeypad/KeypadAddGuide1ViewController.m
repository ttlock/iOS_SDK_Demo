//
//  KeypadAddGuide1ViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/5/28.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "KeypadAddGuide1ViewController.h"
#import "KeypadAddGuide2ViewController.h"
#import "KeypadAddViewController.h"

@interface KeypadAddGuide1ViewController ()
@property (nonatomic, strong) LockModel *lockModel;
@end

@implementation KeypadAddGuide1ViewController

- (instancetype)initWithLockModel:(LockModel *)lockModel{
    if (self = [super init]) {
        _lockModel = lockModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = LS(@"添加无线键盘");
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"keypad_image_1"]];
    [imageView sizeToFit];
    [self.view addSubview:imageView];
    
    UILabel *describeLabel = [UILabel new];
    describeLabel.text = LS(@"摸亮无线键盘\n\n当键盘闪烁时点击“下一步”");
    describeLabel.textColor = UIColor.blackColor;
    describeLabel.numberOfLines = 0;
    describeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:describeLabel];
    
    UIButton *nextButton = [self setupButtonTitle:LS(@"下一步") titleColor:UIColor.blackColor selector:@selector(nextButtonCLick)];
    UIButton *guide2Button = [self setupButtonTitle:LS(@"无线键盘无闪烁") titleColor:UIColor.lightGrayColor selector:@selector(guide2ButtonCLick)];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(imageView.frame.size);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(describeLabel.mas_top);
    }];
    
    [describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(20);
        make.centerY.equalTo(self.view);
    }];
    
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(describeLabel);
        make.height.mas_equalTo(45);;
        make.bottom.equalTo(guide2Button.mas_top).offset(-30);
    }];
    
    [guide2Button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.left.equalTo(nextButton);
        make.bottom.equalTo(self.view).offset(-50);
    }];
    
}

- (void)nextButtonCLick{
    KeypadAddViewController *vc = [[KeypadAddViewController alloc] initWithLockModel:_lockModel];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)guide2ButtonCLick{
    KeypadAddGuide2ViewController *vc = [[KeypadAddGuide2ViewController alloc] initWithLockModel:_lockModel];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIButton *)setupButtonTitle:(NSString *)title titleColor:(UIColor *)titleColor selector:(SEL)selector{
    UIButton *button = [UIButton new];
//    button.titleLabel.font = [UIFont systemFontOfSize:35];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    button.layer.cornerRadius = 6;
    button.layer.masksToBounds = YES;
    button.layer.borderColor = titleColor.CGColor;
    button.layer.borderWidth = 0.5;
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    return button;
}

@end
