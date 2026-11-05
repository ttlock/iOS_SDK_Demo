//
//  AppDelegate.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/4.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "AppDelegate.h"
#import "SceneDelegate.h"
#import "UserModel.h"
#import "HomeViewController.h"
#import "LoginViewController.h"
#import "NavigationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    TTLock.printLog = YES;
    [TTLock setupBluetooth:^(TTBluetoothState state) {
        NSLog(@"##############  TTLock is working, bluetooth state: %ld  ##############",(long)state);
    }];
    
    return YES;
}

- (void)configureWindowForScene:(UIWindowScene *)windowScene {
    _window = [[UIWindow alloc] initWithWindowScene:windowScene];
    _window.backgroundColor = UIColor.whiteColor;
    if ([UserModel isLogin]) {
        [self showHomeViewController];
    } else {
        [self showLoginViewController];
    }
    [_window makeKeyAndVisible];
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    UISceneConfiguration *configuration = [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
    configuration.delegateClass = [SceneDelegate class];
    return configuration;
}

- (void)showLoginViewController{
    _window.rootViewController = [LoginViewController new];
}

- (void)showHomeViewController{
    NavigationController *naviegationController = [[NavigationController alloc] initWithRootViewController:[HomeViewController new]];
    _window.rootViewController = naviegationController;
}


@end
