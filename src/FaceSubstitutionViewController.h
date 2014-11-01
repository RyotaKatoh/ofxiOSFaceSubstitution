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
    
    dispatch_queue_t main_queue;
    dispatch_queue_t sub_queue;
    
    BOOL usePhotoLibrary;
    
}

- (void)openCamera;
- (void)openPhotoLibrary;
- (void)getMaskedImage;

- (IBAction)retry:(id)sender;
- (IBAction)facebook:(id)sender;
- (IBAction)twitter:(id)sender;
- (IBAction)save:(id)sender;

- (void)hideAllButton;
- (void)showAllButton;

@property (retain, nonatomic) IBOutlet UIButton *facebookButton;
@property (retain, nonatomic) IBOutlet UIButton *twitterButton;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet UIButton *retryButton;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UILabel *savedLabel;
@end
