//
//  ConfirmationViewController.h
//  Bevy
//
//  Created by CompanyName on 1/2/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "PJRSignatureView.h"

/**
 * This class is used to confirm the delevery status.
 */
@interface ConfirmationViewController : UIViewController<UITextViewDelegate,ParseWSDelegate>

@property (strong ,nonatomic) IBOutlet TPKeyboardAvoidingScrollView *objScroll;
@property (nonatomic,strong) IBOutlet UITextField *txtFirstName;
@property (nonatomic,strong) IBOutlet UITextField *txtLasatName;
@property (nonatomic,strong) IBOutlet UITextView *txtAddress;
@property (nonatomic,strong) IBOutlet UITextField *txtPhoneNumber;
@property (nonatomic,strong) IBOutlet UITextView *txtSignature;

@property (nonatomic,strong) IBOutlet UILabel *lblFirstName;
@property (nonatomic,strong) IBOutlet UILabel *lblLastName;
@property (nonatomic,strong) IBOutlet UILabel *lblAddress;
@property (nonatomic,strong) IBOutlet UILabel *lblPhoneNumber;
@property (nonatomic,strong) IBOutlet UILabel *lblSignature;
@property (nonatomic,strong) IBOutlet UILabel *lblAmnt;

@property (nonatomic,strong) IBOutlet UIButton *btnSubmit;
@property (nonatomic,strong) IBOutlet UIButton *btnCancel;
@property (nonatomic,strong) IBOutlet UIButton *btnProblemWithOrder;
@property (nonatomic,strong) IBOutlet UIButton *btnOrderAndCheck;
@property (nonatomic, strong) IBOutlet UIView *viewPopUp;
@property (nonatomic, strong) IBOutlet UITextView *textViewProblemWithOrder;
@property (nonatomic, strong) IBOutlet UIView *viewBootomButtonView;
@property (nonatomic, strong) IBOutlet UILabel *placeHolderProblemWith;
@property (nonatomic, strong) IBOutlet UIView *confirmationPopUp;
@property (nonatomic, strong) IBOutlet UIView *viewProblemWith;
@property (nonatomic,strong) IBOutlet PJRSignatureView *objSignView;

@property (nonatomic,strong) MBProgressHUD *HUD;
@property(nonatomic, retain) WS_Helper *objWSHelper;
@property (nonatomic, retain) NSDictionary *dictDetails;
@property (nonatomic, strong) UIImage *imageSelected;
@property (strong , nonatomic) NSDictionary *dictAddressDetails;

/**
 *  clearSignatureClicked ,This method is called when user click on cross button.
 *  @param btnBackClicked, to clear the signature view.
 */
-(IBAction)clearSignatureClicked:(id)sender;
/**
 *  btnSubmitClicked ,This method is called when user click on submit button.
 *  @param btnSubmitClicked, to submit with delivered status.
 */
-(IBAction)btnSubmitClicked:(id)sender;
/**
 *  btnPhoneNumberClicked ,This method is called when user click on phone number button.
 *  @param btnPhoneNumberClicked, to make a call to customer.
 */
-(IBAction)btnPhoneNumberClicked:(id)sender;
/**
 *  btnProbleWithOreder ,This method is called when user click on problem with order button.
 */
-(IBAction)btnProbleWithOreder:(id)sender;
/**
 *  btnOrderChecked ,This method is called when user click on button order checked button.
 */
-(IBAction)btnOrderChecked:(id)sender;
/**
 *  btnCancelOrderChecked ,This method is called when user click on cancel order button.
 *  @param btnCancelOrderChecked, navigates to cancel order screen.
 */
-(IBAction)btnCancelOrderChecked:(UIButton*)sender;

@end