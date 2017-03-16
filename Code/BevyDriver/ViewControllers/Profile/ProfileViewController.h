//
//  ProfileViewController.h
//  Bevy
//
//  Created by CompanyName on 12/20/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "UIDateTimePicker.h"
#import "NPRImageView.h"

/**
 * This class is used to show user's profile details.
 */

@interface ProfileViewController : UIViewController<CustomDateTimePickerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate,ParseWSDelegate>

@property (nonatomic,strong) IBOutlet UITextField *txtFirstName;
@property (nonatomic,strong) IBOutlet UITextField *txtLasatName;
@property (nonatomic,strong) IBOutlet UITextField *txtEmailID;
@property (nonatomic,strong) IBOutlet UITextField *txtPhoneNumber;

@property (nonatomic,strong) IBOutlet UILabel *lblProfileName;
@property (nonatomic,strong) IBOutlet UILabel *lblFirstName;
@property (nonatomic,strong) IBOutlet UILabel *lblLastName;
@property (nonatomic,strong) IBOutlet UILabel *lblEmailID;
@property (nonatomic,strong) IBOutlet UILabel *lblPhoneNumber;
@property (nonatomic,strong) IBOutlet UILabel *lblBirthDay;

@property (nonatomic,strong) IBOutlet UIImageView *lineChangePwd;
@property (nonatomic,strong) IBOutlet UIImageView *lineMycards;

@property (nonatomic,strong) IBOutlet UIButton *btnLogout;
@property (nonatomic,strong) IBOutlet UIButton *btnChangePassword;
@property (nonatomic,strong) IBOutlet UIButton *btnDone;

@property (nonatomic,strong) IBOutlet NPRImageView *imgProfile;
@property (nonatomic,strong) IBOutlet UIButton *btnBirthday,*btnImageSelect;

@property (nonatomic, strong) UIImage *imageSelected;
@property(nonatomic, retain) UIImagePickerController *objImagePicker;
@property (nonatomic, retain) NSTimer *timer;
@property (strong ,nonatomic) UIDateTimePicker *objDatePicker;
@property (strong ,nonatomic) IBOutlet TPKeyboardAvoidingScrollView *objScroll;

@property (nonatomic,strong) MBProgressHUD *HUD;
@property(nonatomic, retain) WS_Helper *objWSHelper;
@property(nonatomic, retain) NSDictionary *dictProfileDetails;
@property(nonatomic, assign) BOOL isPickerOpened;

/**
 *  btnBackClicked ,This method is called when user click on Back button.
 *  @param btnBackClicked, pop to previus screen.
 */
-(IBAction)btnBackClicked:(id)sender;
/**
 *  clickOnChangePwd ,This method is called when user click on Change Password button.
 *  @param clickOnChangePwd, navigates to change password screen.
 */
-(IBAction)clickOnChangePwd:(id)sender;
/**
 *  clickOnLogout ,This method is called when user click on Logout button.
 *  @param clickOnLogout, Loged out successfully, pop to login page.
 */
-(IBAction)clickOnLogout:(id)sender;

@end