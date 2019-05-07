//
//  GuideGatewayViewController.m
//  TTLockSourceCodeDemo
//
//  Created by 王娟娟 on 2019/4/28.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "GuideGatewayViewController.h"
#import "RoundCornerButton.h"
#import "ChooseGatewayViewController.h"

@interface GuideGatewayViewController ()

@end

@implementation GuideGatewayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    // Do any additional setup after loading the view.
}
- (void)setupView{
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *imageName = @"G2Introduce";
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [imageView sizeToFit];
    [self.view addSubview:imageView];
    
    UILabel *describeLabel = [UILabel new];
    describeLabel.numberOfLines = 0;
    describeLabel.textAlignment = NSTextAlignmentCenter;
    describeLabel.text = LS(@"After the gateway is powered back on, click ”Add“");
    [self.view addSubview:describeLabel];
    
    RoundCornerButton *nextButton = [RoundCornerButton buttonWithTitle:LS(@"Next") cornerRadius:4 borderWidth:0.5];
    [nextButton addTarget:self action:@selector(nextButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(imageView.frame.size);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).inset(30+ 80);
    }];
    [describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view.bounds.size.width - 40);
        make.centerX.equalTo(self.view);
        make.top.equalTo(imageView.mas_bottom).offset(40);
    }];
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.centerX.equalTo(describeLabel);
        make.height.mas_equalTo(50);
        make.top.equalTo(describeLabel.mas_bottom).offset(60);
    }];
}
- (void)nextButtonClick{
    ChooseGatewayViewController *vc = [ChooseGatewayViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
