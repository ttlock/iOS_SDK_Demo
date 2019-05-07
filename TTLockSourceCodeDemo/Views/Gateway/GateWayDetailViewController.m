//
//  GateWayDetailVC.m
//  TTLockSourceCodeDemo
//
//  Created by 王娟娟 on 2019/4/28.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "GateWayDetailViewController.h"
#import "GatewayListLockTableViewController.h"
#import "GatewayUpgradeViewController.h"

@interface GateWayDetailViewController ()
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation GateWayDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.gatewayModel.gatewayName;
    
    NSString *gatewayLockStr =  [NSString stringWithFormat:@"%@(%@:%@)",LS(@"Bound lock"),LS(@"Number"),self.gatewayModel.lockNum];
    if (_gatewayModel.gatewayVersion  == GatewayG2) {
        self.dataArray = @[@[gatewayLockStr,LS(@"Gateway upgrade")],@[LS(@"Delete Gateway")]];
    }else{
        self.dataArray = @[@[gatewayLockStr],@[LS(@"Delete Gateway")]];
    }
   
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.dataArray[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];
   
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        GatewayListLockTableViewController *vc = [[GatewayListLockTableViewController alloc]init];
        vc.gatewayModel = self.gatewayModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.section == 0 && indexPath.row == 1) {
        GatewayUpgradeViewController  *vc = [[GatewayUpgradeViewController alloc]init];
        vc.gatewayModel = self.gatewayModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self.view showToastLoading];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS(@"Do you want to delete it ?") message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:LS(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            [self.view hideToast];
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:LS(@"Delete") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [NetUtil deleteGatewayWithGatewayId:self.gatewayModel.gatewayId completion:^(id info, NSError *error) {
                if (error) {
                    [self.view showToastError:error];
                    return ;
                }
                [self.view hideToast];
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
    
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
