//
//  ChooseGatewayViewController.m
//  TTLockSourceCodeDemo
//
//  Created by 王娟娟 on 2019/4/28.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "ChooseGatewayViewController.h"
#import "GatewayModel.h"
#import "Gateway2AddViewController.h"

@interface ChooseGatewayViewController ()
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic,assign) BOOL isUseful;
@end

@implementation ChooseGatewayViewController
- (void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.dataArray== nil){
        self.dataArray = [NSMutableArray array];
    }
    // Do any additional setup after loading the view.
    [TTGateway startScanGatewayWithBlock:^(TTGatewayScanModel *model) {
        if (model.RSSI == 127) {
            return ;
        }
        
        BOOL contain = NO;
        BOOL isExchangePosition = NO;
        for (GatewayModel *containModel in self.dataArray ) {
            if ([containModel.gatewayMac isEqualToString:model.gatewayMac]) {
                if (containModel.RSSI != model.RSSI ) {
                    contain = NO;
                    [self.dataArray removeObject:containModel];
                    break;
                }
                containModel.searchTime = [NSDate date];
                contain = YES;
                break;
            }
        }
        
        
        if (!contain) {
            GatewayModel *containModel = [GatewayModel new];
            containModel.gatewayName = model.gatewayName;
            containModel.gatewayMac = model.gatewayMac;
            containModel.isInited = NO;
            containModel.RSSI = model.RSSI;
            containModel.searchTime = [NSDate date];
            isExchangePosition = YES;
            
            //最强的排在上边,插入排序
            int sortIndex = 0;
            for (int i = 0 ; i < self.dataArray.count ; i ++) {
                GatewayModel *containmodel = self.dataArray[i];
                if (model.RSSI > containmodel.RSSI) {
                    sortIndex = i;
                    break;
                }
                sortIndex = i + 1;
            }
            
            [self.dataArray insertObject:containModel  atIndex:sortIndex];
        }
    }];
   
    _isUseful = YES;
    [self reloadView];
 
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    _isUseful = NO;
    [TTGateway stopScanGateway];
        

}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = LS(@"Select gateway");
}
- (void)reloadView{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_isUseful == YES) {
            //超过5秒钟没有被搜索到 状态就要改变
            NSMutableArray *tempArray = [self.dataArray copy];
            for (GatewayModel *model in tempArray) {
                if (model.searchTime.timeIntervalSinceNow < - 3) {
                    [self.dataArray removeObject:model];
                }
            }
            [self reloadView];
        }
        
    });
    
    [self.tableView reloadData];
}

#pragma mark ---- UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    GatewayModel *model = self.dataArray[indexPath.row];
    cell.textLabel.text = model.gatewayName;
    cell.detailTextLabel.text = model.isInited ? @"" : @"+";
    cell.textLabel.textColor = model.isInited ? UIColor.lightGrayColor : UIColor.redColor;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:35];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GatewayModel *model = self.dataArray[indexPath.row];
    
    [self.view showToastLoading];
    [TTGateway connectGatewayWithGatewayMac:model.gatewayMac block:^(TTGatewayConnectStatus connectStatus) {
        if (connectStatus == TTGatewayConnectSuccess) {
            [TTGateway stopScanGateway];
            Gateway2AddViewController *vc = [[Gateway2AddViewController alloc]init];
            vc.gatewayMac =  model.gatewayMac;
            [self.navigationController pushViewController:vc animated:YES];
            
            [self.view hideToast];
            
        }else{
            [self.view hideToast];
        }
    }];
    
}
- (void)dealloc{
    NSLog(@"******************* %@ 被销毁了 *******************",NSStringFromClass([self class]));
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
