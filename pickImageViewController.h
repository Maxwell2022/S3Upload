//
//  pickImageViewController.h
//  uploadS3Tutorial
//
//  Created by Maxime Aoustin on 12/04/2014.
//  Copyright (c) 2014 Maxime Aoustin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSS3/AWSS3.h>
#import "Contants.h"

@interface pickImageViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, AmazonServiceRequestDelegate>
{
}

@property (nonatomic, retain) AmazonS3Client *s3;

-(IBAction)ButtonPickImage:(id)sender;

@end
