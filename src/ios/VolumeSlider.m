//
//  	VolumeSlider.m
//  	Volume Slider Cordova Plugin
//
//  	Created by Tommy-Carlos Williams on 20/07/11. Updated by Samuel Michelot on 11/05/1013
//  	Copyright 2011 Tommy-Carlos Williams. All rights reserved.
//      MIT Licensed
//

#import "VolumeSlider.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation VolumeSlider

@synthesize mpVolumeViewParentView, myVolumeView, callbackId;

float userVolume  = 0.2;
UISlider* volumeViewSlider = nil;

#ifndef __IPHONE_3_0
@synthesize webView;
#endif

-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (VolumeSlider*)[super initWithWebView:theWebView];
    return self;
}


#pragma mark -
#pragma mark VolumeSlider

- (void) createVolumeSlider:(CDVInvokedUrlCommand *)command
{
    NSLog(@"In createVolumeSlider");
    NSArray* arguments = [command arguments];

    self.callbackId = command.callbackId;
    NSUInteger argc = [arguments count];

    if (argc < 3) { // at a minimum we need x origin, y origin and width...
        return;
    }

    if (self.mpVolumeViewParentView != NULL) {
        // 	return;//already created, don't need to create it again
    }

    CGFloat originx,originy;
    CGFloat height = 30;
    CGFloat width = 100;

    originx = [[arguments objectAtIndex:0] floatValue];
    originy = [[arguments objectAtIndex:1] floatValue];
    if (argc > 2) {
        width = [[arguments objectAtIndex:2] floatValue];
    }
    if (argc > 3) {
        height = [[arguments objectAtIndex:3] floatValue];
    }

    // preset colors
    NSString * colorMinimumSlider = @"#FFFFFF";
    NSString * colorMaximumSlider = @"#FFFFFF";
    if (argc > 4) {
        colorMinimumSlider = [arguments  objectAtIndex:4];
    }
    if (argc > 5) {
        colorMaximumSlider = [arguments  objectAtIndex:5];
    }

    CGRect viewRect = CGRectMake(originx,originy,width,height);

    self.mpVolumeViewParentView = [[UIView alloc] initWithFrame:viewRect];

    [self.webView.superview addSubview:self.mpVolumeViewParentView];

    self.mpVolumeViewParentView.backgroundColor = [UIColor clearColor];
    self.myVolumeView = [[MPVolumeView alloc] initWithFrame:self.mpVolumeViewParentView.bounds];
    [mpVolumeViewParentView addSubview:self.myVolumeView];
    self.myVolumeView.showsVolumeSlider = NO;

    /****** Removed all this in favour of setting maximum/minimumTrackTintColor
     *      BUT this causes a bug in iOS 8 (see http://www.openradar.appspot.com/19915414)
     *      so I only apply my colors if we run iOS >=9, older devices get standard look

    // Set color for Slider images before handle (minimum) and after handle (maximum)
    CGSize sz = CGSizeMake(3,3);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(sz.height,sz.height), NO, 0);

    // minimum: im1
    [[UIColor colorFromHexString:colorMinimumSlider] setFill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0,0,sz.height,sz.height)] fill];
    UIImage* im1 = UIGraphicsGetImageFromCurrentImageContext();

    // maximum: im2
    [[UIColor colorFromHexString:colorMaximumSlider] setFill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0,0,sz.height,sz.height)] fill];
    UIImage* im2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // attach im1 to minimum slider
    [self.myVolumeView]
    [self.myVolumeView setMinimumVolumeSliderImage:
     [im1 resizableImageWithCapInsets:UIEdgeInsetsMake(2,2,2,2)
                         resizingMode:UIImageResizingModeStretch]
                                          forState:UIControlStateNormal];

    // attach im1 to maximum slider
    [self.myVolumeView setMaximumVolumeSliderImage:
     [im2 resizableImageWithCapInsets:UIEdgeInsetsMake(2,2,2,2)
                         resizingMode:UIImageResizingModeStretch]
                                          forState:UIControlStateNormal];

     **************************************************************************************/

    volumeViewSlider = nil;
    for (UIView *view in [self.myVolumeView subviews]) {
        if ([view isKindOfClass:[UISlider class]]) {
            volumeViewSlider = (UISlider*)view;
            NSLog(@"Found MPVolumeslider :  %f" ,userVolume );

            if ([[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending) {
                volumeViewSlider.minimumTrackTintColor = [UIColor colorFromHexString:colorMinimumSlider];
                volumeViewSlider.maximumTrackTintColor = [UIColor colorFromHexString:colorMaximumSlider];
            }

            break;
        }
    }
    userVolume = volumeViewSlider.value;

}

- (void)showVolumeSlider:(CDVInvokedUrlCommand *)command
{
    self.myVolumeView.showsVolumeSlider = YES;
    self.mpVolumeViewParentView.hidden = NO;

}

- (void)hideVolumeSlider:(CDVInvokedUrlCommand *)command
{
    self.mpVolumeViewParentView.hidden = YES;
    self.myVolumeView.showsVolumeSlider = NO;
}

- (void)setVolumeSlider:(CDVInvokedUrlCommand *)command
{
    self.mpVolumeViewParentView.hidden = YES;
    self.myVolumeView.showsVolumeSlider = NO;

    NSArray* arguments = [command arguments];
    NSUInteger argc = [arguments count];

    if (argc < 1) { // at a minimum we need the value to be set...
        return;
    }
    float setVolume = [[arguments objectAtIndex:0] floatValue];

    [volumeViewSlider setValue:setVolume animated:NO];
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];

}

- (void)resetVolumeSlider:(CDVInvokedUrlCommand *)command
{
    [volumeViewSlider setValue:userVolume animated:NO];
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];

}
@end


@implementation UIColor (Private)

// taken from http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
