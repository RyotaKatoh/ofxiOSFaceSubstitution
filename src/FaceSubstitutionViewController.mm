//
//  FaceSubstitutionViewController.m
//  FaceSubstitutionCamera
//
//  Created by Ryota Katoh on 2014/10/26.
//
//

#import "FaceSubstitutionViewController.h"
#include "ofxiOSExtras.h"
#import "SVProgressHUD/SVProgressHUD.h"

@interface FaceSubstitutionViewController ()

@end

@implementation FaceSubstitutionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    main_queue = dispatch_get_main_queue();
    sub_queue = dispatch_queue_create("imageProcessing", 0);
    

    myApp = (ofApp *)ofGetAppPtr();
    
    social = [[SocialFrameworksUtil alloc]init];
    [social setViewController:self];
    
    [self hideAllButton];
    [self.retryButton.imageView setTintColor:[UIColor whiteColor]];
    [self.facebookButton.imageView setTintColor:[UIColor whiteColor]];
    [self.twitterButton.imageView setTintColor:[UIColor whiteColor]];
    [self.saveButton.imageView setTintColor:[UIColor whiteColor]];
    
    usePhotoLibrary = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {

    [_imageView release];
    [_retryButton release];
    [_facebookButton release];
    [_twitterButton release];
    [_saveButton release];
    [_savedLabel release];
    [super dealloc];
}

#pragma mark - touch event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    
    if(myApp->myScene == ready){
        
        myApp->myScene = openCamera;
        [self openCamera];
        //[self openPhotoLibrary];
        
    }
//    else if(myApp->myScene == preview){
//    
//        myApp->maskTakenPhotoforDebug(img);
//        
//        maskedImage = [UIImage imageWithCGImage:UIImageFromOFImage(myApp->maskedImage).CGImage];
//        self.imageView.image = maskedImage;
//    }
    
}


#pragma mark - UIImagePickerControllerDelegate

- (void)openCamera{

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
    
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        [imagePickerController setAllowsEditing:NO];
        [imagePickerController setDelegate:self];
        [imagePickerController setEditing:NO];
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
        
        
    }
    else{
    
        NSLog(@"camera invalid");
        
    }
    
}

- (void)openPhotoLibrary{

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
    
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [imagePickerController setAllowsEditing:NO];
        [imagePickerController setDelegate:self];
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
        
        
    }
    else{
    
        NSLog(@"photo library invalid");
        
        
    }
    
    usePhotoLibrary = YES;
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{


    [SVProgressHUD show];
    
    dispatch_async(sub_queue, ^{

        [self dismissViewControllerAnimated:YES completion:nil];
        
        dispatch_async(main_queue, ^{
            
            pickedImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
            
            [self getMaskedImage];
            [self showAllButton];
            [SVProgressHUD dismiss];
            
            if(!myApp->cloneReady){
            
                [self showNotDetectedLabel];
                
            }

        });
        
    });

    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{

    [self dismissViewControllerAnimated:YES completion:nil];

    self.imageView.image = nil;
    [self hideAllButton];
    
    myApp->myScene = ready;
    
}

UIImage * UIImageFromOFImage( ofImage & img ){
    int width = img.width;
    int height =img.height;
    
    int nrOfColorComponents = 1;
    
    if (img.type == OF_IMAGE_GRAYSCALE) nrOfColorComponents = 1;
    else if (img.type == OF_IMAGE_COLOR) nrOfColorComponents = 3;
    else if (img.type == OF_IMAGE_COLOR_ALPHA) nrOfColorComponents = 4;
    
    int bitsPerColorComponent = 8;
    int rawImageDataLength = width * height * nrOfColorComponents;
    BOOL interpolateAndSmoothPixels = NO;
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGDataProviderRef dataProviderRef;
    CGColorSpaceRef colorSpaceRef;
    CGImageRef imageRef;
    GLubyte *rawImageDataBuffer = img.getPixels();
    dataProviderRef = CGDataProviderCreateWithData(NULL, rawImageDataBuffer, rawImageDataLength, nil);
    colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    imageRef = CGImageCreate(width, height, bitsPerColorComponent, bitsPerColorComponent * nrOfColorComponents, width * nrOfColorComponents, colorSpaceRef, bitmapInfo, dataProviderRef, NULL, interpolateAndSmoothPixels, renderingIntent);
    UIImage * uimg = [UIImage imageWithCGImage:imageRef];
    return uimg;
    
}

#pragma mark - utility

- (void)getMaskedImage{

    ofxiOSUIImageToOFImage(pickedImage, img);
    
    if(!usePhotoLibrary)
        img.rotate90(45);
    myApp->maskTakenPhoto(img);
    
    maskedImage = [UIImage imageWithCGImage:UIImageFromOFImage(myApp->maskedImage).CGImage];
    self.imageView.image = maskedImage;
    
    myApp->myScene = preview;
    
}

- (IBAction)retry:(id)sender {
    
    [self openCamera];
    
    //myApp->setMaskFaceTraker();
    //myApp->setDebugTracker();
}

- (IBAction)facebook:(id)sender {
    
    [social postToFacebook:maskedImage];
    
}

- (IBAction)twitter:(id)sender {
    
    [social postToTwitter:maskedImage];
    
    
}

- (IBAction)save:(id)sender {
    
    UIImageWriteToSavedPhotosAlbum(maskedImage, self, @selector(finishSaving:didFinishSavingWithError:contextInfo:), nil);
 
}

- (void)finishSaving:(UIImage *)_image didFinishSavingWithError:(NSError*)_error contextInfo:(void *)_contextinfo{
    
    if(_error){
        
        self.savedLabel.text = @"error!";
    
    }
    else{
    
        self.savedLabel.text = @"success!";
        
    }
    
    [[self.savedLabel layer]setCornerRadius:8.0];
    [self.savedLabel setClipsToBounds:YES];
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [[self.savedLabel layer]addAnimation:animation forKey:nil];
    
    self.savedLabel.hidden = NO;
    NSTimer *tm = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(hideSavedLabel:) userInfo:nil repeats:NO];

}

- (void)hideSavedLabel:(NSTimer*)timer{

    self.savedLabel.hidden = YES;
    
}

- (void)showNotDetectedLabel{


    
    self.savedLabel.text = @"Please Try Again...";
        
    [[self.savedLabel layer]setCornerRadius:8.0];
    [self.savedLabel setClipsToBounds:YES];
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [[self.savedLabel layer]addAnimation:animation forKey:nil];
    
    self.savedLabel.hidden = NO;
    NSTimer *tm = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(hideSavedLabel:) userInfo:nil repeats:NO];
  
    
}



- (void)hideAllButton{
    
    self.retryButton.hidden     = YES;
    self.facebookButton.hidden  = YES;
    self.twitterButton.hidden   = YES;
    self.saveButton.hidden      = YES;
    self.savedLabel.hidden      = YES;
    
}

- (void)showAllButton{

    self.retryButton.hidden     = NO;
    self.facebookButton.hidden  = NO;
    self.twitterButton.hidden   = NO;
    self.saveButton.hidden      = NO;
    
}


@end
