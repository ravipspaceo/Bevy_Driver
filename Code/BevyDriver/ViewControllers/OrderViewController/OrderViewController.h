//
//  OrderViewController.h
//  Bevy
//
//  Created by CompanyName on 1/2/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PJRSignatureView.h"

/**
 * This class is used to show the pending orders.
 */
@interface OrderViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ParseWSDelegate>

@property (strong , nonatomic) IBOutlet UILabel *lblTransaction,*lblAmnt,*lblDesc,*lblPopUpMesg,*lblPopUpTimeUp,*lblPopUpTitle;
@property (strong , nonatomic) IBOutlet UIView *objPopUp,*objInner;
@property (strong , nonatomic) IBOutlet UIView *objTrans;
@property (strong , nonatomic) IBOutlet UIView *viewTimer;
@property (nonatomic, strong) IBOutlet UIView *outerView;
@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UIView *problemView;

@property (strong , nonatomic) IBOutlet UITableView *tblOrder;
@property (strong , nonatomic) IBOutlet UITableView *tblOrderDetail;
@property (strong , nonatomic) NSDictionary *dictAddressDetails;
@property (strong , nonatomic) NSMutableArray *arrOrderDetails;

@property (nonatomic, strong) IBOutlet UIButton *btnOder,*btnOrderDetails,*btnCursorMap,*btnDecline,*btnAccept;
@property (nonatomic, strong) IBOutlet UIButton *popYes,*popNo,*popOk;

@property (nonatomic, strong) NSString *timerValue;

@property(nonatomic, assign) BOOL isRejected;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSTimer *timerRoute;
@property (nonatomic, assign) BOOL isFirstTime;
@property (nonatomic, assign) BOOL isFromProblem;
@property (nonatomic, strong) NSString *strProblemText;
@property (nonatomic, strong) IBOutlet UITextView *textViewProblemWithOrder;
@property (nonatomic,strong) IBOutlet PJRSignatureView *objSignView;

@property(nonatomic, retain) CLLocation *driverLocation;

@property (nonatomic, strong) WS_Helper *objWSHelper;
@property (nonatomic, strong) MBProgressHUD *HUD;

/**
 * This method is used to stop timer.
 */
-(void)invalidateTimer;

/**
 * This method is used to stop timer route.
 */
-(void)invalidateTimerRoute;

@end