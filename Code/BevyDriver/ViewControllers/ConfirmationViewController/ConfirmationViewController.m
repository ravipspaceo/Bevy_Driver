//
//  ConfirmationViewController.m
//  Bevy
//
//  Created by CompanyName on 1/2/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import "ConfirmationViewController.h"
#import "CancelOrderViewController.h"
#import "ProfileViewController.h"
#import "HomeViewController.h"
#import "OrderViewController.h"

@interface ConfirmationViewController ()

@end

@implementation ConfirmationViewController

#pragma mark - ViewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.objWSHelper = [[WS_Helper alloc] init];
    [self.objWSHelper setTarget:self];
    [self viewTitleFont];
    [self setBackButton];
    [self addToolBar];
    self.navigationItem.rightBarButtonItem = [GlobalManager getnavigationRightButtonWithTarget:self :@"userProfile"];
    self.confirmationPopUp.layer.borderWidth = 1.0;
    self.confirmationPopUp.layer.borderColor = [[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]CGColor];
    self.confirmationPopUp.layer.cornerRadius = 5.0;
    self.lblAmnt.text = [GlobalManager getAppDelegateInstance].strTransaction;
    NSArray *array = [[self.dictAddressDetails valueForKey:@"customer_name"] componentsSeparatedByString:@" "];
    if([array count])
    {
        self.txtFirstName.text = [array objectAtIndex:0];
        if ([[array objectAtIndex:1] length]) {
           self.txtLasatName.text = [array objectAtIndex:1];
        }
        else{
            self.txtLasatName.text = [array lastObject];
        }
        
    }
    self.txtAddress.text = [self.dictAddressDetails valueForKey:@"delivery_address"];
    self.txtPhoneNumber.text = [self.dictAddressDetails valueForKey:@"customer_phone"];
    self.btnOrderAndCheck.selected = YES;
    self.btnProblemWithOrder.selected = NO;
    self.btnCancel.hidden  = YES;
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    if(self.btnProblemWithOrder.selected == NO)
    {
        self.viewProblemWith.hidden = YES;
        self.objScroll.scrollEnabled = NO;
        CGRect rectTemp = self.lblSignature.frame;
        rectTemp.origin.y = self.objSignView.frame.origin.y+self.objSignView.frame.size.height+10;
        self.btnProblemWithOrder.frame = rectTemp;
        [self.objScroll setContentOffset:CGPointMake(0, 0) animated:YES];

        if (IS_IPHONE_4) {
            [self.objScroll setContentSize:CGSizeMake(self.objScroll.frame.size.width, self.objScroll.frame.size.height+100)];
            self.viewBootomButtonView.frame = CGRectMake(self.viewBootomButtonView.frame.origin.x, self.objScroll.frame.size.height+100-self.viewBootomButtonView.frame.size.height-39, self.viewBootomButtonView.frame.size.width, self.viewBootomButtonView.frame.size.height);
        }
        else {
            [self.objScroll setContentSize:CGSizeMake(self.objScroll.frame.size.width, self.objScroll.frame.size.height)];

            self.viewBootomButtonView.frame = CGRectMake(self.viewBootomButtonView.frame.origin.x, self.view.frame.size.height-self.viewBootomButtonView.frame.size.height-39, self.viewBootomButtonView.frame.size.width, self.viewBootomButtonView.frame.size.height);

        }
    }
    if (IS_IPHONE_4) {
        self.objScroll.scrollEnabled = YES;
        [self.objScroll setContentSize:CGSizeMake(self.objScroll.frame.size.width, self.objScroll.frame.size.height+100)];
    }
    int xPosition = ([GlobalManager getAppDelegateInstance].window.frame.size.width - self.btnSubmit.frame.size.width)/2;
    self.btnSubmit.frame = CGRectMake(xPosition, self.btnSubmit.frame.origin.y, self.btnSubmit.frame.size.width, self.btnSubmit.frame.size.height);

    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)btnProfileClicked{
    ProfileViewController *objProfil =[[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
    [self.navigationController pushViewController:objProfil animated:YES];
}

-(void)viewTitleFont
{
    self.title =@"Confirmation";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans-Semibold" size:18],NSFontAttributeName, nil]];
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
    self.txtPhoneNumber.inputAccessoryView = toolbar;
    return toolbar;
}

-(void)doneButtonClicked
{
    if ([self.txtPhoneNumber isFirstResponder])
    {
        [self.txtPhoneNumber resignFirstResponder];
    }
    else if ([self.txtAddress isFirstResponder])
    {
        [self.txtAddress resignFirstResponder];
    }
}
#pragma mark- UITextView Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
   self.placeHolderProblemWith.hidden = self.textViewProblemWithOrder.text.length;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    self.placeHolderProblemWith.hidden = self.textViewProblemWithOrder.text.length;
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView;
{
  self.placeHolderProblemWith.hidden = self.textViewProblemWithOrder.text.length;
}

#pragma mark- IBActions Methods

-(IBAction)btnCancelOrderChecked:(UIButton*)sender;
{
    CancelOrderViewController *objCanc =[[CancelOrderViewController alloc]initWithNibName:@"CancelOrderViewController" bundle:nil];
    [self.navigationController pushViewController:objCanc animated:YES];
}
/**
 * btnSubmitClicked, This method is called when user clicks on submit button.
 * It will be call the confirmationWS.
 * and signature validation will be occurred if customer didn't sign.
 */
-(IBAction)btnSubmitClicked:(id)sender{
   
    
    if (self.btnProblemWithOrder.selected==YES)
    {
        if(self.textViewProblemWithOrder.text.length == 0 ||  [self.textViewProblemWithOrder.text isEqualToString:@" "] || [self.textViewProblemWithOrder.text isEqualToString:@"     "] || [self.textViewProblemWithOrder.text isEqualToString:@"    "] || [self.textViewProblemWithOrder.text isEqualToString:@"  "])
        {
            [UIAlertView showWithTitle:APPNAME message:@"Please enter your concern" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
            }];
            return;
        }
        else{
            [self.view endEditing:YES];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
            [hud setLabelText:@"Please wait"];
            [self callProblemWithOrder];
        }
    }
     else if(self.objSignView.incrImage == nil)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please take signature" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.objSignView becomeFirstResponder];
        }];
    }
    
    else
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
        [hud setLabelText:@"Please wait"];
        [hud setMode:MBProgressHUDModeAnnularDeterminate];
        [hud setDimBackground:YES];
        
        [self performSelector:@selector(callConfirmationWS) withObject:nil afterDelay:0.1];
    }
}

/**
 * clearSignatureClicked, This method is called when user clicks on clear(*) button.
 * It will clear the previous signature which is done by customer.
 */
-(IBAction)clearSignatureClicked:(id)sender
{
    [self.objSignView clearSignature];
}
/**
 * btnProbleWithOreder, This method is called when user clicks on ProbleWithOreder(*) button.
 *
 */

-(IBAction)btnProbleWithOreder:(id)sender
{
    self.btnProblemWithOrder.selected =YES;
    self.objSignView.hidden = YES;
    self.lblSignature.hidden = YES;
    self.btnOrderAndCheck.selected = !self.btnProblemWithOrder.selected;
    self.viewProblemWith.hidden = NO;
     CGRect rectTemp = self.btnOrderAndCheck.frame;
     self.objScroll.scrollEnabled = YES;
    rectTemp.origin.y = self.btnOrderAndCheck.frame.origin.y+self.btnOrderAndCheck.frame.size.height+13;
    self.btnProblemWithOrder.frame = rectTemp;
    self.textViewProblemWithOrder.hidden = NO;
    self.viewProblemWith.frame = CGRectMake(self.viewProblemWith.frame.origin.x, self.btnProblemWithOrder.frame.origin.y+self.btnProblemWithOrder.frame.size.height+10, self.viewProblemWith.frame.size.width, self.viewProblemWith.frame.size.height);
     [self.objScroll setContentSize:CGSizeMake(self.objScroll.frame.size.width, self.objScroll.frame.size.height+600)];
}

/**
 * btnOrderChecked, This method is called when user clicks on OrderChecked(*) button.
 * 
 */
-(IBAction)btnOrderChecked:(id)sender;
{
    self.btnOrderAndCheck.selected =YES;
    if (IS_IPHONE_4) {
        self.objScroll.scrollEnabled = YES;
    }
    else
        self.objScroll.scrollEnabled = NO;
    self.objSignView.hidden = NO;
    self.lblSignature.hidden = NO;
    self.btnProblemWithOrder.selected = !self.btnOrderAndCheck.selected;
    self.viewProblemWith.hidden = YES;
    CGRect rectTemp = self.lblSignature.frame;
    rectTemp.origin.y = self.objSignView.frame.origin.y+self.objSignView.frame.size.height+10;
    self.btnProblemWithOrder.frame = rectTemp;
    [self.objScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.objScroll setContentSize:CGSizeMake(self.objScroll.frame.size.width, self.objScroll.frame.size.height+300)];
}

-(IBAction)btnPhoneNumberClicked:(id)sender
{
    [self makeCallToCustomer:nil];
}
-(void)makeCallToCustomer:(UIButton*)sender
{
    
    [UIAlertView showConfirmationDialogWithTitle:[NSString stringWithFormat:@"Call : %@",[self.dictAddressDetails valueForKey:@"customer_phone"]] message:nil firstButtonTitle:@"Cancel" secondButtonTitle:@"Ok" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if(buttonIndex==1)
        {
            @autoreleasepool
            {
                NSURL *target = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"tel:%@", [self.dictAddressDetails valueForKey:@"customer_phone"]]];
                [[UIApplication sharedApplication] openURL:target];
            }
        }
    }];
}

#pragma mark - WS calling methods

-(void)callConfirmationWS
{
//    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Uploading"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] forKey:@"driver_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:ORDER_ID] forKey:@"order_id"];
    [self.objWSHelper setServiceName:@"Confirmation"];
    NSData *imageData =  UIImagePNGRepresentation(self.objSignView.incrImage);
    [self.objWSHelper sendRequestWithPostURL:[WS_Urls getConfirmTheOrderURL:params] andParametrers:nil andData:imageData andFileKey:@"customer_signature_image" andExtention:@"png" andMymeTye:@"image/png"];
}
-(void)callProblemWithOrder
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] forKey:@"driver_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:ORDER_ID] forKey:@"order_id"];
    [params setObject:self.textViewProblemWithOrder.text forKey:@"problem_text"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] forKey:@"user_id"];
    [self.objWSHelper setServiceName:@"OrderProblem"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getSendOrderProblem:params]];
}

#pragma mark - ParseWSDelegate Methods
-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    if (!response)
    {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:DRIVER_ONLINE_STATUS];
    NSMutableDictionary *dictResults=(NSMutableDictionary *)response;
    if([helper.serviceName isEqualToString:@"Confirmation"])
    {
        
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
                        NSLog(@"Success %@",dictResults);
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex)
             {
                 [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:ORDER_STATUS];
                 [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ORDER_ID];
                 [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:INPROCESS];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 for (UIViewController *objVC in [GlobalManager getAppDelegateInstance].objNavController.viewControllers)
                 {
                     if([objVC isKindOfClass:[OrderViewController class]])
                     {
                         OrderViewController *viewController = (OrderViewController *)objVC;
                         [viewController invalidateTimerRoute];
                     }
                     
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
            NSLog(@"Failure %@",dictResults);
            
            [UIAlertView showWithTitle:APPNAME message:[GlobalManager getValurForKey:[dictResults objectForKey:@"settings"] :@"message"] handler:nil];
            return;
        }
    }
    if([helper.serviceName isEqualToString:@"OrderProblem"])
    
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            OrderViewController *objOV = [[OrderViewController alloc] init];
            objOV.isFromProblem = YES;
            objOV.strProblemText  = self.textViewProblemWithOrder.text;
            [self.navigationController pushViewController:objOV animated:YES];
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