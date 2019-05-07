//
//  KJXIAChooseSSIDView.m
//  Sciener
//
//  Created by 王娟娟 on 2019/3/11.
//  Copyright © 2019 sciener. All rights reserved.
//

#import "ChooseSSIDView.h"

#define kPickViewH 352
#define kToolBarH 44

@interface ChooseSSIDView ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ChooseSSIDView

- (instancetype)init{
    
    if (self = [super init]) {
        self.backgroundColor = RGB_A(0, 0, 0, 0.4);
        self.frame = [UIApplication sharedApplication].keyWindow.bounds;
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [self setupView];
    }
    return self;
}

- (void)setupView{
    UITableView *ssidTableview = [[UITableView alloc] init];
    ssidTableview.backgroundColor = [UIColor whiteColor];
    ssidTableview.delegate = self;
    ssidTableview.dataSource = self;
    ssidTableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self addSubview:ssidTableview];
    self.ssidTableView = ssidTableview;
    
    UIView *toolBar = [UIView new];
    toolBar.backgroundColor = [UIColor whiteColor];
    [self addSubview:toolBar];
    
    UIView *line = [UIView new];
    line.backgroundColor = RGB_A(0, 0, 0, 0.2);
    [toolBar addSubview:line];
    
    UIButton *cancelBtn = [UIButton new];
    [cancelBtn setTitle:LS(@"Cancel") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:cancelBtn];
    
    UIActivityIndicatorView *testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [toolBar addSubview:testActivityIndicator];
    testActivityIndicator.color = [UIColor blackColor]; // 改变圈圈的颜色为红色； iOS5引入
    [testActivityIndicator startAnimating]; // 开始旋转
    self.testActivityIndicator = testActivityIndicator;
    //    [testActivityIndicator stopAnimating]; // 结束旋转
    //    [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
   
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(toolBar);
        make.height.mas_equalTo(0.5);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = LS(@"Select WiFi");
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:16];
    [toolBar addSubview:titleLabel];
    
    [ssidTableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(kPickViewH);
        make.bottom.equalTo(self);
    }];
    
    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(ssidTableview);
        make.bottom.equalTo(ssidTableview.mas_top);
        make.height.mas_equalTo(kToolBarH);
    }];
    
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(toolBar);
        make.left.equalTo(toolBar).offset(19);
    }];

    [testActivityIndicator mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@24);
        make.centerY.equalTo(toolBar);
        make.right.equalTo(toolBar).offset(-19);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.left.equalTo(cancelBtn.mas_right);
        //        make.right.equalTo(sureBtn.mas_left);
        make.centerX.equalTo(self);
        make.top.bottom.equalTo(toolBar);
    }];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.ssidArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1
                                     reuseIdentifier:@"cell"];
    }
    NSDictionary *dic = self.ssidArr[indexPath.row];
    cell.textLabel.text = dic[@"SSID"];
    int rssi =  [dic[@"RSSI"] intValue];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"rssi:%d",rssi];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.chooseSSIDBlock) {
         NSDictionary *dic = self.ssidArr[indexPath.row];
        self.chooseSSIDBlock(dic[@"SSID"]);
        [self dismiss];
    }
}

- (void)dismiss{
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
