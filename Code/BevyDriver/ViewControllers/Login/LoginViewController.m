//
//  LoginViewController.m
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "LoginViewController.h"
#import "ChangePasswordViewController.h"
#import "OrderViewController.h"
#import "HomeViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.btnLogin.layer.borderColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0].CGColor;
    self.btnLogin.layer.borderWidth = 1.0;
    self.objWSHelper = [[WS_Helper alloc] init];
    [self.objWSHelper setTarget:self];
    if (TARGET_IPHONE_SIMULATOR)
    {
        self.txtEmailId.text = @"krid3@mailinator.com";
        self.txtPwd.text = @"12345678";
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:EMAIL_ADDRESS] != nil)
    {
        [self.txtEmailId setText:[[NSUserDefaults standardUserDefaults] objectForKey:EMAIL_ADDRESS]];
        [self.txtPwd setText:[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD]];
    }
}

#pragma mark - IBAction Methods
/**
 * btnLoginClicked, TThis method is called when user clicks on login button.
 * Login into the application when user clicks on this button.
 * it will check valid email and password of the user.
 */
-(IBAction)btnLoginClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
    NSString *strError;
    if (![Validations validateEmail:self.txtEmailId.text error:&strError])
    {
        [UIAlertView showWithTitle:APPNAME message:strError handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtEmailId becomeFirstResponder];
        }];
    }
    else if (self.txtPwd.text.length==0)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter password" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtPwd becomeFirstResponder];
        }];
    }
    else
    {
        [self callLoginWS];
        return;
    }
}

/**
 * clickedOnForgotPwd, TThis method is called when user clicks on forgotPassword button.
 * It appears the popup to fill the valid emailid.
 * and send password to given emailid.
 */
-(IBAction)clickedOnForgotPwd:(id)sender
{
    [self.view endEditing:YES];
    [UIAlertView showForgotPassword:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         if (buttonIndex == 1)
         {
             [self.view endEditing:YES];
             NSString *error;
             if ([Validations validateEmail:[alertView textFieldAtIndex:0].text error:&error])
             {
                 self.strForgotEmailAddress =[alertView textFieldAtIndex:0].text;
                 [self callForgotpassword:[alertView textFieldAtIndex:0].text];
                 return;
             }
             else
             {
                 [UIAlertView showErrorWithMessage:NSLocalizedStringFromTable(error, @"InfoPlist", nil) myTag:444 handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                  {
                      [self clickedOnForgotPwd:nil];
                  }];
             }
         }
         else
         {
             [self.view endEditing:YES];
         }
     }];
}

#pragma mark - UITextField Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - WS calling methods
-(void)callLoginWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:self.txtEmailId.text  forKey:@"email_id"];
    [params setObject:self.txtPwd.text  forKey:@"password"];
    
    [params setObject:([[[NSUserDefaults standardUserDefaults] objectForKey:LATITUDE] length])?[[NSUserDefaults standardUserDefaults] objectForKey:LATITUDE]:@"0"  forKey:@"driver_lat"];
    [params setObject:([[[NSUserDefaults standardUserDefaults] objectForKey:LONGITUDE] length])?[[NSUserDefaults standardUserDefaults] objectForKey:LONGITUDE]:@"0"  forKey:@"driver_long"];
    [params setObject:kDeviceType forKey:@"device_type"];
        
    [params setObject:([[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN] length])?[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN]:@"1111111111" forKey:@"device_token"];

    self.objWSHelper.serviceName = @"Login";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getLoginURL:params]];
}

-(void)callDriverStatusWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID]  forKey:@"driver_id"];
    self.objWSHelper.serviceName = @"DRIVERSTATUS";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getDriverStatusURL:params]];
}

-(void)callForgotpassword:(NSString *)emailAddress
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:emailAddress  forKey:@"email_id"];
    self.objWSHelper.serviceName = @"ForgotPassword";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getForgotPasswordURL:params]];
}

#pragma mark - ParseWSDelegate Methods
-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    if (!response)
    {
        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
        return;
    }
    NSMutableDictionary *dictResults=(NSMutableDictionary *)response;
    if([helper.serviceName isEqualToString:@"Login"])
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AUTO_LOGIN];
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"driver_id"] forKey:DRIVER_ID];
            [[NSUserDefaults standardUserDefaults] setValue:self.txtEmailId.text forKey:EMAIL_ADDRESS];
            [[NSUserDefaults standardUserDefaults] setValue:self.txtPwd.text forKey:PASSWORD];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self callDriverStatusWS];
            return;
        }
        else
        {
            [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
    else if([helper.serviceName isEqualToString:@"DRIVERSTATUS"])
    {
        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"order_status"] forKey:ORDER_STATUS];
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"order_id"] forKey:ORDER_ID];
            //[[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:DRIVER_ONLINE_STATUS] forKey:DRIVER_ONLINE_STATUS];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:DRIVER_ONLINE_STATUS] forKey:DRIVER_ONLINE_STATUS];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:ORDER_STATUS];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ORDER_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        HomeViewController *objHomeVC = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
        OrderViewController *objOrderVC = [[OrderViewController alloc] initWithNibName:@"OrderViewController" bundle:nil];
        NSString *orderStatus = [[NSUserDefaults standardUserDefaults] objectForKey:ORDER_STATUS];
        if ([orderStatus isEqualToString:@""])
            [self.navigationController pushViewController:objHomeVC animated:YES];
        else
            [self.navigationController setViewControllers:@[self, objHomeVC,objOrderVC] animated:YES];
    }
    else//@"ForgotPassword"
    {
        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
        
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            [UIAlertView showWithTitle:APPNAME message:[NSString stringWithFormat:@"A link to reset your password will be sent to %@", self.strForgotEmailAddress] handler:nil];
            return;
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}

@end