//
//  NavigationController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/22.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "NavigationController.h"

@interface NavigationController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>


@end

@implementation NavigationController
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    if (self = [super initWithRootViewController:rootViewController]) {
        [self setBarButtonItemMethod];
    }
    return self;
}

- (void) setBarButtonItemMethod
{
    UIBarButtonItem *buttonItem = [UIBarButtonItem appearance];
    NSMutableDictionary *textAtrributeDict = [NSMutableDictionary dictionary];
    textAtrributeDict[NSFontAttributeName] = [UIFont systemFontOfSize:14];
    textAtrributeDict[NSForegroundColorAttributeName] = [UIColor blackColor];
    [buttonItem setTitleTextAttributes:textAtrributeDict forState:UIControlStateNormal];//普通状态
    [buttonItem setTitleTextAttributes:textAtrributeDict forState:UIControlStateHighlighted];//高亮状态
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.interactivePopGestureRecognizer.delegate = self;
    self.delegate = self;
}

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed =YES;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"navigation_item_left_back"] forState:UIControlStateNormal];
        button.frame = (CGRect){CGPointZero,CGSizeMake(40, 44)};
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
        [button addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    
    [super pushViewController:viewController animated:animated];
}

- (void)backViewController{
    [self popViewControllerAnimated:true];
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.childViewControllers.count > 1;
}

@end
