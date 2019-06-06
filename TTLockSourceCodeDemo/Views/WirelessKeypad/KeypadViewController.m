//
//  KeypadViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/5/28.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "KeypadViewController.h"

@interface KeypadViewController ()
@property (nonatomic, strong) KeypadModel *keypadModel;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation KeypadViewController

- (instancetype)initWithKeypadModel:(KeypadModel *)keypadModel{
    if (self = [super init]) {
        _keypadModel = keypadModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArray = @[LS(@"名称"),LS(@"MAC")];
    
    self.title = _keypadModel.wirelessKeyboardName;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Delete") style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClick)];
    self.tableView.tableFooterView = [UIView new];
}

- (void)deleteButtonClick{
    [self.view showToastLoading];
    [NetUtil deleteWirelessKeypadWithID:_keypadModel.wirelessKeyboardId completion:^(id info, NSError *error) {
        if (error) {
            [self.view showToastError:error];
            return ;
        }
        
        NOTIF_POST(RELOAD_KEYPAD_TABLE_NOTIFICATION, nil);
        [self.view showToast:LS(@"Success") completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.text = _dataArray[indexPath.row];
    
    switch (indexPath.row) {
        case 0:
            cell.detailTextLabel.text = _keypadModel.wirelessKeyboardName;
            break;
        case 1:
            cell.detailTextLabel.text = _keypadModel.wirelessKeyboardMac;
            break;
        case 2:
            cell.detailTextLabel.text = _keypadModel.wirelessKeyboardNumber;
            break;
            
        default:
            break;
    }
    
    return cell;
}


@end
