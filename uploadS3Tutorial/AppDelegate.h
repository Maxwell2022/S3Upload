//
//  AppDelegate.h
//  uploadS3Tutorial
//
//  Created by Maxime Aoustin on 12/04/2014.
//  Copyright (c) 2014 Maxime Aoustin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)userLoggedIn;
- (void)userLoggedOut;

@end
