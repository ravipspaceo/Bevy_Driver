//
//  CancelOrderViewController.h
//  Bevy
//
//  Created by CompanyName on 1/2/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This class is used to cancel Order screen with cancellation note.
 */
@interface CancelOrderViewController : UIViewController<UITextViewDelegate,ParseWSDelegate>

@property (nonatomic,strong) IBOutlet UITextView *txtCancelation;
@property (nonatomic,strong) IBOutlet UILabel *labelPlaceHolder;
@property (nonatomic,strong) IBOutlet UILabel *lblAmnt;
@property (nonatomic, strong) WS_Helper *objWSHelper;
@property (nonatomic, strong) MBProgressHUD *HUD;
/**
 * This method is called when user clicks on submit button.
 * after clicking submit button cancelOrderWS will be called.
 */
-(IBAction)btnSubmitClicked:(id)sender;
@end
