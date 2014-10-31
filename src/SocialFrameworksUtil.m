//
//  SocialFrameworksUtil.m
//  FaceSubstitutionCamera
//
//  Created by Ryota Katoh on 2014/10/30.
//
//

#import "SocialFrameworksUtil.h"

@implementation SocialFrameworksUtil


- (void)setViewController:(UIViewController *)vc{

    viewController = vc;
    
}

- (void)postToFacebook:(UIImage *)image{

    SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [vc setInitialText:@"via Unknown Camera"];
    [vc addImage:image];
//    [vc addURL:[NSURL URLWithString:@"http://www.apple.com"]];
    
    [viewController presentViewController:vc animated:YES completion:nil];
    
}

- (void)postToTwitter:(UIImage *)image{

    SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [vc setInitialText:@" #Unknown Camera"];
    [vc addImage:image];
//    [vc addURL:[NSURL URLWithString:@"http://www.apple.com"]];
    
    [viewController presentViewController:vc animated:YES completion:nil];
    
    
}

@end
