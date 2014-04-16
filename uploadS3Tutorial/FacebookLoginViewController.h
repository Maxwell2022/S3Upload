//
//  FacebookLoginViewController.h
//  uploadS3Tutorial
//
//  Created by Maxime Aoustin on 16/04/2014.
//  Copyright (c) 2014 Maxime Aoustin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FacebookLoginViewController : UIViewController <FBLoginViewDelegate>
{
}

-(IBAction)btnConnect:(id)sender;
-(IBAction)testSegue:(id)sender;
-(void)successLoginTransition;

@end
