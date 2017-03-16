//
//  ProfileViewController.m
//  Bevy
//
//  Created by CompanyName on 12/20/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "ProfileViewController.h"
#import "ChangePasswordViewController.h"
#import "OrderViewController.h"
#import "LoginViewController.h"

@interface ProfileViewController ()
{
    NSDate *dateLimit;
}
@end

@implementation ProfileViewController

#pragma mark - ViewLifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
    [self viewTitleFont];
    [self setLeftButton];
    [self setProfileRightBarButton];
    [self setUpUI];
    [self imgSized];
    self.objWSHelper = [[WS_Helper alloc] init];
    [self.objWSHelper setTarget:self];
    [self.objScroll setContentSize:CGSizeMake(0, CGRectGetMaxY(self.btnDone.frame)+20 )];
}

-(void)viewWillAppear:(BOOL)animated
{
    dateLimit = [GlobalManager getDateFromBefore18Years];
    if(!self.isPickerOpened)
    {
       [self callViewProfileWS];
        return;
    }
    else
        self.isPickerOpened = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instance Methods
-(void)setUpUI
{
    self.txtFirstName.tag=self.txtLasatName.tag=self.txtPhoneNumber.tag=self.txtEmailID.tag=100;
    self.btnChangePassword.tag=self.btnLogout.tag=100;
    self.txtPhoneNumber.inputAccessoryView  = [self addToolBar];
    
    if (IS_IPHONE_6){
        self.btnChangePassword.imageEdgeInsets = UIEdgeInsetsMake(0,355,0,0);
    }
    else if (IS_IPHONE_6_PLUS){
        self.btnChangePassword.imageEdgeInsets = UIEdgeInsetsMake(0,394,0,0);
    }
}

-(void)viewTitleFont
{
    self.title =@"Profile";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans" size:18],NSFontAttributeName, nil]];
}

-(void)imgSized
{
    self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.height/2;
    self.imgProfile.clipsToBounds = YES;
    self.imgProfile.layer.borderWidth=3.0f;
    self.imgProfile.layer.borderColor=[UIColor colorWithRed:69/255.0 green:220/255.0 blue:188/255.0 alpha:1.0].CGColor;
}

-(void)btnMenuClicked
{
    [self.view endEditing:YES];
}

-(void)btnProfileDonePressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IBAction Methods
/**
 * clickOnLogout, This method is called when user clicks on logout button.
 * logout from the application when user clicks on this button.
 * and it redirects to login page.
 */
-(IBAction)clickOnLogout:(id)sender
{
    [UIAlertView showConfirmationDialogWithTitle:APPNAME message:@"Are you sure you want to logout?" firstButtonTitle:@"No" secondButtonTitle:@"Yes" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if(buttonIndex == 1)
        {
            [self callDriverAvailabilityONWS];
            return;
        }
    }];
}

/**
 * clickOnChangePwd, This method is called when driver clicks on change password button.
 * It will be navigates to the next view - ChangePassword when user clicked on this button.
 */
-(IBAction)clickOnChangePwd:(id)sender
{
    ChangePasswordViewController *objChangepwd=[[ChangePasswordViewController alloc] init];
    [self.navigationController pushViewController:objChangepwd animated:YES];
}

#pragma mark - CustomDatePicker
/**
 * btnDateOfBirthClicked, This method is called when user clicks on DateOfBirth button.
 * A dateofbirth picker will be appeared when user clicked on this button for selecting the birthdate of user.
 */
-(IBAction)btnDateOfBirthClicked:(UIButton*)sender
{
    [self.view endEditing:YES];
    if (!self.objDatePicker)
    {
        self.objDatePicker = [[UIDateTimePicker alloc] init];
        self.objDatePicker.delegate = self;
    }
    if (!(IS_IPHONE_6 || IS_IPHONE_6_PLUS))
        [self.objScroll setContentOffset:CGPointMake(0, 260) animated:YES];
    
    [self.objDatePicker initWithDatePicker:CGRectMake(0,0,[GlobalManager getAppDelegateInstance].window.frame.size.width, 432) inView:self.view ContentSize:CGSizeMake([GlobalManager getAppDelegateInstance].window.frame.size.width, 216) pickerSize:CGRectMake(0, 20, [GlobalManager getAppDelegateInstance].window.frame.size.width, 216) pickerMode:UIDatePickerModeDate dateFormat:@"MM/dd/yyyy" minimumDate:nil maxDate:dateLimit setCurrentDate:
    [NSDate date] Recevier:(UIButton*)sender barStyle:UIBarStyleDefault toolBartitle:@"Select Birthdate" textColor:[UIColor whiteColor]];
}

-(void)pickerDoneWithDate:(NSDate *)doneDate
{
    [self.btnBirthday setSelected:YES];
    [self.objScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(void)cancel_clicked:(id)sender
{
    [self.objScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark - ToolBar

-(UIToolbar *)addToolBar
{
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.items = [NSArray arrayWithObjects:
                     [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                     [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked)],
                     nil];
    toolbar.tintColor=[UIColor whiteColor];
    [toolbar sizeToFit];
    self.txtPhoneNumber.inputAccessoryView = toolbar;
    return toolbar;
}

-(void)doneButtonClicked
{
    [self.txtPhoneNumber endEditing:YES];
    [self.txtEmailID becomeFirstResponder];
}

#pragma mark - UIImagePickerController Methods
/**
 * btnChangeImageClick, This method is called when user clicks on ChangeImage button.
 * A image picker will be appeared when user clicked on this button for selecting the image.
 */
-(IBAction)btnChangeImageClick:(id)sender
{
    UIActionSheet *objActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use camera", @"Choose existing", nil];
    objActionSheet.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
    [objActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        // From Gallery
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self performSelector:@selector(openPicker:) withObject:imagePicker afterDelay:0.1];
        }
    }
    else if (buttonIndex == 0)
    {
        // Use Camera
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            [self performSelector:@selector(openPicker:) withObject:imagePicker afterDelay:0.1];
        }
        else
        {
            [UIAlertView showWarningWithMessage:@"Your device don't have camera" handler:nil];
        }
    }
}

-(void) openPicker:(UIImagePickerController *)imagePicker{
    self.isPickerOpened = YES;
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.imageSelected = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.imgProfile setImage:self.imageSelected];
    self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.height/2;
    self.imgProfile.clipsToBounds = YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - doneClicked
/**
 * doneClicked, This method is called when user clicks on done button.
 * all the driver details will be saved when user click on this button.
 */
-(IBAction)doneClicked:(id)sender
{
    NSString *strError;
    if([self.txtFirstName.text length]==0)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter first name" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtFirstName becomeFirstResponder];
        }];
    }else  if([self.txtLasatName.text length]==0)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter last name" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtLasatName becomeFirstResponder];
        }];
    }
    else if ([self.txtPhoneNumber.text length]==0)
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter phone number" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtPhoneNumber becomeFirstResponder];
        }];
    }
    else if (![Validations validatePhone:self.txtPhoneNumber.text ])
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please enter 10-11 digits phone number" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtPhoneNumber becomeFirstResponder];
        }];
    }
    else if (![Validations validateEmail:self.txtEmailID.text error:&strError])
    {
        [UIAlertView showWithTitle:APPNAME message:strError handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.txtEmailID becomeFirstResponder];
        }];
    }
    else if ([self.btnBirthday.titleLabel.text isEqualToString:@"Birthday"] )
    {
        [UIAlertView showWithTitle:APPNAME message:@"Please select birthday" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self.btnBirthday becomeFirstResponder];
        }];
    }
    else
    {
        if(self.imageSelected == nil)
            [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
        else
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
            [hud setLabelText:@"Please wait"];
            [hud setMode:MBProgressHUDModeAnnularDeterminate];
            [hud setDimBackground:YES];
        }
       [self performSelector:@selector(callEditProfileWS) withObject:nil afterDelay:0.1];
    }
}

#pragma mark - Webservices Methods

-(void)callViewProfileWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] forKey:@"user_id"];
    self.objWSHelper.serviceName = @"ViewProfile";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getViewProfileURL:params]];
}

-(void)callEditProfileWS
{
    NSString *birthDate = @"0000-00-00";
    if(![self.btnBirthday.titleLabel.text isEqualToString:@"Birthday"])
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        NSDate *date = [formatter dateFromString:self.btnBirthday.titleLabel.text];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        birthDate = [formatter stringFromDate:date];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] forKey:@"user_id"];
    [params setObject:self.txtEmailID.text forKey:@"email_id"];
    [params setObject:self.txtFirstName.text forKey:@"first_name"];
    [params setObject:self.txtLasatName.text forKey:@"last_name"];
    [params setObject:self.txtPhoneNumber.text forKey:@"mobile_no"];
    [params setObject:birthDate forKey:@"date_of_birth"];
    
    [self.objWSHelper setServiceName:@"UPDATE_PROFILE"];
    if(self.imageSelected == nil)
    {
        [self.objWSHelper sendRequestWithURL:[WS_Urls getEditProfileURL:params]];
    }
    else
    {
        NSData *imageData =  UIImagePNGRepresentation(self.imageSelected);
        [self.objWSHelper sendRequestWithPostURL:[WS_Urls getEditProfileURL:params] andParametrers:nil andData:imageData andFileKey:@"profile_image" andExtention:@"png" andMymeTye:@"image/png"];
    }
}

-(void)callDriverAvailabilityONWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] forKey:@"user_id"];
    [params setObject:@"No" forKey:@"available"];
    
    self.objWSHelper.serviceName = @"DriverAvailability";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getDriverAvailabilityURL:params]];
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
    if([helper.serviceName isEqualToString:@"ViewProfile"])
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            self.dictProfileDetails = [NSDictionary dictionaryWithDictionary:[[dictResults objectForKey:@"data"] objectAtIndex:0]];
            
            NSString *dateOfBirth = [self.dictProfileDetails valueForKey:@"date_of_birth"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *date = [formatter dateFromString:dateOfBirth];
            [formatter setDateFormat:@"MM/dd/yyyy"];
            
            NSString *name = [NSString stringWithFormat:@"%@ %@", [self.dictProfileDetails valueForKey:@"first_name"], [self.dictProfileDetails valueForKey:@"last_name"]];
            [self.lblProfileName setText:[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            [self.txtFirstName setText:[self.dictProfileDetails valueForKey:@"first_name"]];
            [self.txtLasatName setText:[self.dictProfileDetails valueForKey:@"last_name"]];
            [self.txtPhoneNumber setText:[self.dictProfileDetails valueForKey:@"mobile_no"]];
            [self.btnBirthday setTitle:[formatter stringFromDate:date] forState:UIControlStateNormal];
            [self.btnBirthday setTitle:[formatter stringFromDate:date] forState:UIControlStateSelected];
            [self.txtEmailID setText:[self.dictProfileDetails valueForKey:@"email_id"]];
            
            [self.imgProfile setImageWithContentsOfURL:[NSURL URLWithString:[self.dictProfileDetails valueForKey:@"profile_image"]] placeholderImage:[UIImage imageNamed:@"thumb_placeholder"]];
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
    else if([helper.serviceName isEqualToString:@"UPDATE_PROFILE"])
    {
        
        [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if(buttonIndex == 0)
            {
                 self.lblProfileName.text = [NSString stringWithFormat:@"%@ %@", self.txtFirstName.text , self.txtLasatName.text];
            }
        }];
        return;
    }
    else if([helper.serviceName isEqualToString:@"DriverAvailability"])
    {
        //Success or failure need to logout from app;
        NSArray *array =  [GlobalManager getAppDelegateInstance].objNavController.viewControllers;
        for (NSInteger index = [array count]-1; index >= 0; index--)
        {
            UIViewController *objVC = [array objectAtIndex:index];
            if([objVC isKindOfClass:[OrderViewController class]])
            {
                OrderViewController *viewController = (OrderViewController *)objVC;
                [viewController invalidateTimer];
            }
            
            if ([objVC isKindOfClass:[LoginViewController class]])
            {
                [[GlobalManager getAppDelegateInstance].objNavController popToViewController:objVC animated:YES];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:AUTO_LOGIN];
                break;
            }
        }
    }
    else
    {
        [UIAlertView showWithTitle:APPNAME message:[GlobalManager getValurForKey:[dictResults objectForKey:@"settings"] :@"message"] handler:nil];
        return;
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}

@end