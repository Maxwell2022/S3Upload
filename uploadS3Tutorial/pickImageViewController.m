//
//  pickImageViewController.m
//  uploadS3Tutorial
//
//  Created by Maxime Aoustin on 12/04/2014.
//  Copyright (c) 2014 Maxime Aoustin. All rights reserved.
//

#import "pickImageViewController.h"
#import <AWSRuntime/AWSRuntime.h>

@interface pickImageViewController ()

@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIButton *pickImageButton;
@property (nonatomic, strong) S3TransferManager *tm;

@end



@implementation pickImageViewController

@synthesize s3 = _s3;

#pragma mark - Prepare View
- (void)viewDidLoad
{
    [self prepareView];
    
    if (self.s3 == nil) {
        self.s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.view sizeToFit];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)prepareView
{
    self.title = @"S3 Uploader";
    
    self.progressBar.Progress = (float)0;
    self.progressBar.Hidden = YES;
    
    self.pickImageButton.layer.cornerRadius = 2;
    self.pickImageButton.layer.borderWidth = 2;
    self.pickImageButton.layer.borderColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1].CGColor;
    
    self.percentLabel.font = [UIFont systemFontOfSize:12];
    self.percentLabel.text = @"";
    
    self.imagePreview.contentMode = UIViewContentModeScaleAspectFit;
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [self prefersStatusBarHidden];
}

#pragma mark - View Actions

-(IBAction)ButtonPickImage:(id)sender
{
    UIImagePickerController *imagePicker =
    [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    // imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - Image Picker

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get the selected image.
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Convert the image to JPEG data.
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);

    // Display the preview
    self.imagePreview.image = image;
    
    [self processDelegateUpload:imageData];
    
    // Initialise the progress bar to 0 and display it
    self.progressBar.progress = (float)0;
    self.progressBar.hidden = NO;
    self.progressBar.progressTintColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - AWS S3 upload

- (void)processDelegateUpload:(NSData *)imageData
{
    NSString *guid = [[NSUUID UUID] UUIDString];
    NSString *destFile = [NSString stringWithFormat:@"%@.%@", guid, @"jpeg"];
    
    // Upload image data.  Remember to set the content type.
    S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:destFile inBucket:S3_BUCKET];
    por.contentType = @"image/jpeg";
    por.data = imageData;
    por.delegate = self;
    por.cannedACL = [S3CannedACL publicRead];
    
    // Put the image data into the specified s3 bucket and object.
    [self.s3 putObject:por];
}

-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    self.progressBar.hidden = YES;
    self.percentLabel.text = @"Uploaded!";
    [self showAlertMessage:@"The image was successfully uploaded." withTitle:@"Upload Completed"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
    [self showAlertMessage:error.description withTitle:@"Upload Error"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)request:(AmazonServiceRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse called: %@", response);
}

-(void)request:(AmazonServiceRequest *)request didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData called");
}

-(void)request:(AmazonServiceRequest *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
    
    float x = (float)totalBytesWritten;
    float y = (float)totalBytesExpectedToWrite;
    float ratio = x / y;
    
    self.progressBar.progress = ratio;
    self.percentLabel.text = [NSString stringWithFormat:@"%.2f %%", (ratio*100)];
    
    if (ratio == 1){
        self.progressBar.progressTintColor = [UIColor greenColor];
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end
