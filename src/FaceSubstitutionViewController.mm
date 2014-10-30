//
//  FaceSubstitutionViewController.m
//  FaceSubstitutionCamera
//
//  Created by Ryota Katoh on 2014/10/26.
//
//

#import "FaceSubstitutionViewController.h"
#include "ofxiOSExtras.h"


@interface FaceSubstitutionViewController ()

@end

@implementation FaceSubstitutionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    myApp = (ofApp *)ofGetAppPtr();
    
    social = [[SocialFrameworksUtil alloc]init];
    [social setViewController:self];
    
    
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
    [super dealloc];
}

#pragma mark - touch event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    if(myApp->maskedImage.isAllocated()){
    
        [social postToTwitter:maskedImage];
        
    }
    else{
    
        [self openCamera];
        
    }
    
}


#pragma mark - UIImagePickerControllerDelegate

- (void)openCamera{

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
    
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        [imagePickerController setAllowsEditing:NO];
        [imagePickerController setDelegate:self];
        
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
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    pickedImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self getMaskedImage];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{

    [self dismissViewControllerAnimated:YES completion:nil];

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
    img.rotate90(45);
    myApp->maskTakenPhoto(img);
    
    maskedImage = [UIImage imageWithCGImage:UIImageFromOFImage(myApp->maskedImage).CGImage];
    self.imageView.image = maskedImage;
    
}


@end
