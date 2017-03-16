//
//  LoadingViewController.h
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This class is used to loading the application.
 */
@interface LoadingViewController : UIViewController<ParseWSDelegate>
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *actIndicator;
@property (nonatomic, strong) IBOutlet UIImageView *imageBg;
@property(nonatomic, assign) BOOL isNotificationFired;
@property (nonatomic, retain) WS_Helper *objWSHelper;

@end
