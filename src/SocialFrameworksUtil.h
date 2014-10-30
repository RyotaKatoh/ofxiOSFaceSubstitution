//
//  SocialFrameworksUtil.h
//  FaceSubstitutionCamera
//
//  Created by Ryota Katoh on 2014/10/30.
//
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>

@interface SocialFrameworksUtil : NSObject{

    UIViewController *viewController;
    
}

- (void)setViewController:(UIViewController *)vc;

- (void)postToFacebook:(UIImage *)image;
- (void)postToTwitter:(UIImage *)image;


@end
