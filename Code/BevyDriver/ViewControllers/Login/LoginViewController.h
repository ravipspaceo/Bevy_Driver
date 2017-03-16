//
//  LoginViewController.h
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WS_Helper.h"

/**
 * This class is used to login to the application.
 */
@interface LoginViewController : UIViewController<ParseWSDelegate>

@property (nonatomic,strong) IBOutlet UIButton *btnLogin;
@property (nonatomic,strong) IBOutlet UIButton *btnForgotPwd;
@property (nonatomic,strong) IBOutlet UITextField *txtEmailId;
@property (nonatomic,strong) IBOutlet UITextField *txtPwd;
@property (nonatomic,strong) IBOutlet UIScrollView *scrollVeiw;
@property (nonatomic,strong) IBOutlet UIImageView *imglogo;

@property (nonatomic, strong) WS_Helper *objWSHelper;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, retain) NSString *strForgotEmailAddress;

/**
 *  clickedOnForgotPwd ,This method is called when user click on forgot password button.
 *  @param clickedOnForgotPwd, user can get the password via email.
 */
-(IBAction)clickedOnForgotPwd:(id)sender;
/**
 *  btnLoginClicked ,This method is called when user click on Login button.
 *  @param btnLoginClicked, user can loged in to the application with valid credentials.
 */
-(IBAction)btnLoginClicked:(id)sender;

@end