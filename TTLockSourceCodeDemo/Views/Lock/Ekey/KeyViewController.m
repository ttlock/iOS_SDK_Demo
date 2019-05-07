//
//  LockViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/4.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "KeyViewController.h"


@interface KeyViewController ()
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) KeyModel *keyModel;
@property (nonatomic, strong) LockModel *lockModel;

@property (nonatomic, assign) BOOL longPressed;
@end

@implementation KeyViewController

- (instancetype)initWithLockModel:(LockModel *)lockModel{
    if (self = [super init]) {
        _lockModel = lockModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self setupData];
}

- (void)setupData{
    [self.view showToastLoading];
    [NetUtil adminKeyWithLockId:_lockModel.lockId pageIndex:1 completion:^(KeyModel *info, NSError *error) {
        if (error){
            [self.view showToastError:error];
            return ;
        }
        [self.view hideToast];
        self.keyModel = info;
        self.dataArray= @[LS(@"Unlock"),LS(@"Lock")];
        [self.tableView reloadData];
    }];
}

- (void)setupView{
    self.tableView.rowHeight = 55;
    self.tableView.tableFooterView = [UIView new];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Reset eKey") style:UIBarButtonItemStylePlain target:self action:@selector(resetEkeyClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
//    if ([TTUtil getLockTypeWithLockVersion:_lockModel.lockVersion] == TTLockTypeRemoteControl) {
//        UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewLongPressAction:)];
//        longPressGr.minimumPressDuration = 1.0;
//        [self.tableView addGestureRecognizer:longPressGr];
//    }
    
}

- (void)resetEkeyClick{
    [self.view showToastLoading];
    [TTLock resetEkeyWithLockData:_lockModel.lockData success:^{
        [NetUtil resetEKeyWithLockId:self.lockModel.lockId completion:^(id info, NSError *error) {
            if (error) {
                [self.view showToastError:error];
                return ;
            }
            [self.view showToast:LS(@"Success")];
        }];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        [self.view showToast:errorMsg];
    }];
}

- (void)controlLockAction:(TTControlAction)acton{
    [self.view showToastLoading];
    [TTLock controlLockWithControlAction:acton lockData:_keyModel.lockData success:^(long long lockTime, NSInteger electricQuantity, long long uniqueId) {
        [self.view showToast:LS(@"Success")];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        [self.view showToast:errorMsg];
    }];
}

//#pragma mark - Table view cell long press
//
//-(void)tableViewLongPressAction:(UILongPressGestureRecognizer *)gesture
//{
//    if(gesture.state == UIGestureRecognizerStateBegan)
//    {
//        CGPoint point = [gesture locationInView:self.tableView];
//        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
//        if(indexPath == nil) return ;
//        if (indexPath.row < 2) {
//            _longPressed = YES;
//            [self tableView:self.tableView didLongPressedRowAtIndexPath:indexPath];
//        }
//    }else if(gesture.state == UIGestureRecognizerStateEnded){
//        _longPressed = NO;
//    }
//}
//
//- (void)tableView:(UITableView *)tableView didLongPressedRowAtIndexPath:(NSIndexPath *)indexPath{
//    TTControlAction action = indexPath.row == 0 ? TTControlActionUnlock : TTControlActionLock;
//    [self controlLockAction:action];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if (self.longPressed) [self tableView:tableView didLongPressedRowAtIndexPath:indexPath];
//    });
//}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TTControlAction controlAction = indexPath.row == 0 ? TTControlActionUnlock : TTControlActionLock;
    [self controlLockAction:controlAction];
}

@end
