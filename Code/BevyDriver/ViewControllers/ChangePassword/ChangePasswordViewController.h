//
//  ChangePasswordViewController.h
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

/**
 * This class is used to change the current password.
 */

@interface ChangePasswordViewController : UIViewController<ParseWSDelegate>

@property (nonatomic,strong) IBOutlet UITextField *txtOldPassword;
@property (nonatomic,strong) IBOutlet UITextField *txtNewPassword;
@property (nonatomic,strong) IBOutlet UITextField *txtConfirmPassword;
@property (nonatomic,strong) IBOutlet UIButton *btnDone;

@property (nonatomic,strong) IBOutlet TPKeyboardAvoidingScrollView *scrollview;
@property (nonatomic,strong) IBOutlet UIButton *btnBack;

@property (nonatomic,strong) MBProgressHUD *HUD;
@property(nonatomic, retain) WS_Helper *objWSHelper;

/**
 *  btnBackClicked ,This method is called when user click on Back button.
 *  @param btnBackClicked, pop to previus screen.
 */
-(IBAction)btnBackClicked:(id)sender;
/**
 *  clickedOnDone ,This method is called when user click on Done button.
 *  @param clickedOnDone, password changed successfully.
 */
-(IBAction)clickedOnDone:(id)sender;

@end