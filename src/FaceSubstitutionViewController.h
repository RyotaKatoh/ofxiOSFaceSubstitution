//
//  FaceSubstitutionViewController.h
//  FaceSubstitutionCamera
//
//  Created by Ryota Katoh on 2014/10/26.
//
//

#import <UIKit/UIKit.h>
#include "ofApp.h"
#import "SocialFrameworksUtil.h"


@interface FaceSubstitutionViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>{

    ofApp *myApp;
    
    UIImage *pickedImage;
    
    ofImage img;
    UIImage *maskedImage;
    
    SocialFrameworksUtil *social;
    
}

- (void)openCamera;
- (void)openPhotoLibrary;
- (void)getMaskedImage;

@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@end
