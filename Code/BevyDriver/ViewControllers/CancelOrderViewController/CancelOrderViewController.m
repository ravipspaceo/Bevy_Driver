//
//  CancelOrderViewController.m
//  Bevy
//
//  Created by CompanyName on 1/2/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import "CancelOrderViewController.h"
#import "ConfirmationViewController.h"
#import "ProfileViewController.h"
#import "HomeViewController.h"
@interface CancelOrderViewController ()

@end

@implementation CancelOrderViewController

#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self viewTitleFont];
    self.objWSHelper = [[WS_Helper alloc] init];
    [self.objWSHelper setTarget:self];
    [self setBackButton];
    [self addToolBar];
    self.navigationItem.rightBarButtonItem = [GlobalManager getnavigationRightButtonWithTarget:self :@"userProfile"];
    [self.labelPlaceHolder setFont:[UIFont fontWithName:@"OpenSans-Light" size:12]];
    self.lblAmnt.text = [GlobalManager getAppDelegateInstance].strTransaction;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewTitleFont
{
    self.title =@"Cancel Order";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans" size:18],NSFontAttributeName, nil]];
}

-(void)doneButtonClicked
{
    [self.txtCancelation endEditing:YES];
    if ([self.txtCancelation isFirstResponder])
    {
        [self.txtCancelation resignFirstResponder];
    }
}

#pragma mark - ToolBar
-(UIToolbar *)addToolBar
{
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                     [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked)],nil];
    toolbar.tintColor=[UIColor whiteColor];
    [toolbar sizeToFit];
    self.txtCancelation.inputAccessoryView = toolbar;
    return toolbar;
}

-(void)btnProfileClicked
{
    [self.view endEditing:YES];
    ProfileViewController *objProfil =[[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
    [self.navigationController pushViewController:objProfil animated:YES];
}

#pragma mark- IBActions Methods
-(IBAction)btnSubmitClicked:(id)sender
{
    [self.view endEditing:YES];
    if(![self.txtCancelation.text length])
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter cancellation note" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtCancelation becomeFirstResponder];
        }];
    }
    else
        [self callCancelOrderWS];
}

#pragma mark - UITextViewDelegate Methods
- (void)textViewDidChange:(UITextView *)textView
{
    [self.labelPlaceHolder setHidden:textView.text.length];
}

-(void)callCancelOrderWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] forKey:@"driver_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:ORDER_ID] forKey:@"order_id"];
    [params setObject:self.txtCancelation.text forKey:@"vCancelNote"];
    [self.objWSHelper setServiceName:@"CancelOrder"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getCancelTheOrdersURL:params]];
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
    if([helper.serviceName isEqualToString:@"CancelOrder"])
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex)
             {
                 [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:ORDER_STATUS];
                 [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ORDER_ID];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 for (UIViewController *objVC in [GlobalManager getAppDelegateInstance].objNavController.viewControllers)
                 {
                     if ([objVC isKindOfClass:[HomeViewController class]])
                     {
                         [[GlobalManager getAppDelegateInstance].objNavController popToViewController:objVC animated:YES];
                         break;
                     }
                 }
             }];
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[GlobalManager getValurForKey:[dictResults objectForKey:@"settings"] :@"message"] handler:nil];
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