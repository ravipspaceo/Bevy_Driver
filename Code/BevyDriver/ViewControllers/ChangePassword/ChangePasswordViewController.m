//
//  ChangePasswordViewController.m
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "ChangePasswordViewController.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

#pragma mark - ViewLifeCycle

- (void)viewDidLoad {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [super viewDidLoad];
    self.objWSHelper = [[WS_Helper alloc] init];
    [self.objWSHelper setTarget:self];
     [self.view setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
    [self setBackButton];
     [self viewTitleFont];
    [self setUpUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instance Methods

-(void)setUpUI
{
      self.txtOldPassword.placeholder=@"Old Password";
      self.txtNewPassword.placeholder=@"New Password";
      self.txtConfirmPassword.placeholder=@"Confirm Password";
}

-(void)viewTitleFont
{
    self.title =@"Change Password";
    [self.navigationController.navigationBar setTitleTextAttributes:
    [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans-Semibold" size:18],NSFontAttributeName, nil]];
}

#pragma mark - Action Methods
/**
 * clickedOnDone, This method is called when user clicks on Done button.
 * by clicking on this button user can change password.
 */
-(IBAction)clickedOnDone:(id)sender
{
    [self.view endEditing:YES];
     NSString *strError;
    if (self.txtOldPassword.text.length == 0) {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter current password" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtOldPassword becomeFirstResponder];
        }];
    }
    else if(![Validations validatePasswordLength:self.txtOldPassword.text error:&strError]){
        [UIAlertView showWithTitle:APPNAME message:strError handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtOldPassword becomeFirstResponder];
        }];
    }else if (self.txtNewPassword.text.length == 0){
        [UIAlertView showWithTitle:APPNAME message:@"Please enter new password" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtNewPassword becomeFirstResponder];
        }];
    }else if (![Validations validatePasswordLength:self.txtNewPassword.text error:&strError]){
        [UIAlertView showWithTitle:APPNAME message:strError handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtNewPassword becomeFirstResponder];
        }];
    }else if(self.txtConfirmPassword.text.length == 0){
        [UIAlertView showWithTitle:APPNAME message:@"Please enter confirm password" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtConfirmPassword becomeFirstResponder];
        }];
    }else if(![Validations comparePasswords:self.txtNewPassword.text confirmPassword:self.txtConfirmPassword.text error:&strError]){
            [UIAlertView showWithTitle:APPNAME message:strError handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [self.txtConfirmPassword becomeFirstResponder];
            }];
    }
//    else if(![[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD] isEqualToString:self.txtOldPassword.text]){
//        [UIAlertView showWithTitle:APPNAME message:@"Please enter correct current password." handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            [self.txtOldPassword becomeFirstResponder];
//        }];
//    }
    else{
            [self callChangePassword];
            return;
     }
}

/**
 * btnBackClicked, This method is called when user clicks on Back button.
 * It will be get back to the previous view.
 */
-(IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextField Delegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

#pragma mark - WS calling methods
-(void)callChangePassword
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] forKey:@"user_id"];
    [params setObject:self.txtNewPassword.text  forKey:@"new_password"];
    [params setObject:self.txtOldPassword.text  forKey:@"old_password"];
    self.objWSHelper.serviceName = @"ChangePassword";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getChangePasswordURL:params]];
}

#pragma mark - ParseWSDelegate Methods

-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    if (!response)
    {
        return;
    }
    NSMutableDictionary *dictResults=(NSMutableDictionary *)response;
    if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
    {
        [[NSUserDefaults standardUserDefaults] setValue:self.txtNewPassword.text forKey:PASSWORD];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [UIAlertView showWithTitle:@"Success" message:@" Your password has been successfully changed" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             [self.navigationController popViewControllerAnimated:YES];
         }];
    }
    else
    {
        [UIAlertView showWithTitle:APPNAME message:[GlobalManager getValurForKey:[dictResults objectForKey:@"settings"] :@"message"] handler:nil];
       if(self.txtOldPassword)
       {
           [self.txtOldPassword becomeFirstResponder];
       }
        return;
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}

@end