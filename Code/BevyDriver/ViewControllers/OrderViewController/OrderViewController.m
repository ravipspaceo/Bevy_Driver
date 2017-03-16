//
//  OrderViewController.m
//  Bevy
//
//  Created by CompanyName on 1/2/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import "OrderViewController.h"
#import "OrderTableViewCell.h"
#import "OrderDetailTableViewCell.h"
#import "ConfirmationViewController.h"
#import "CancelOrderViewController.h"
#import "ProfileViewController.h"
#import "DDHTimerControl.h"
#import "RouteDirectionViewController.h"
#import "HomeViewController.h"
#import "ProblemWOrderTableViewCell.h"

#define SECONDS [[[[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_SETTINGS] valueForKey:DRIVER_LOCATION_REFRESH] intValue]

@interface OrderViewController ()
{
    BOOL isPickUp;
    BOOL isAccepted;
}
@property (nonatomic, strong) DDHTimerControl *timerControl;
@property (nonatomic, strong) NSDate *endDate;

@end

@implementation OrderViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.timerValue = [[[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_SETTINGS] objectForKey:@"max_order_response_time"];
    }
    return self;
}

#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.isFirstTime = YES;
    
    isPickUp = YES;
    
    isAccepted = NO;
    
    self.navigationItem.rightBarButtonItem = [GlobalManager getnavigationRightButtonWithTarget:self :@"userProfile"];
    self.objWSHelper = [[WS_Helper alloc] init];
    [self.objWSHelper setTarget:self];
    [GlobalManager getAppDelegateInstance].strTransaction = @"";
    [self.navigationItem setTitle:@"Order"];
    [self setLeftButton];
    [self SetUpUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [GlobalManager getAppDelegateInstance].stopLocationUpdate = YES;
    [self.navigationController setNavigationBarHidden:NO];
    if(self.isFromProblem)
    {
        self.problemView.hidden = NO;
        self.textViewProblemWithOrder.text = self.strProblemText;
        [self.view setBackgroundColor:[UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]];
        [self.tblOrder sizeToFit];
    }
    else
    {
      self.problemView.hidden = YES;
        [self.view setBackgroundColor:[UIColor whiteColor]];

    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callAcceptedOrderWS) name:@"Reload_Order_Details" object:nil];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return NO;
}

/**
 * clearSignatureClicked, This method is called when user clicks on clear(*) button.
 * It will clear the previous signature which is done by customer.
 */
-(IBAction)clearSignatureClicked:(id)sender
{
    [self.objSignView clearSignature];
}
-(void)viewWillDisappear:(BOOL)animated
{
    
}
-(void)SetUpUI
{
    self.tblOrder.hidden = NO;
    self.tblOrderDetail.hidden = YES;
    [self.btnOder setSelected:YES];
    self.objInner.layer.cornerRadius = 5.0;
 
    [self.tblOrderDetail registerNib:[UINib nibWithNibName:@"OrderDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"OrderDetailTableViewCell"];
    
    if(self.isFromProblem)
    {
    [self.tblOrder registerNib:[UINib nibWithNibName:@"ProblemWOrderTableViewCell" bundle:nil] forCellReuseIdentifier:@"ProblemWOrderTableViewCell"];
         [self.navigationItem setTitle:@"Problem with order"];
        self.btnAccept.tag = 103;
        [self.btnAccept setImage:[UIImage imageNamed:((self.isFromProblem)?@"submit_btn":@"delivered")] forState:UIControlStateNormal];
        self.btnDecline.tag = 202;
        [self.btnDecline setImage:[UIImage imageNamed:((self.isFromProblem)?@"cancel_btn":@"cancel-order")] forState:UIControlStateNormal];
    }
    else
    {
       [self.tblOrder registerNib:[UINib nibWithNibName:@"OrderTableViewCell" bundle:nil] forCellReuseIdentifier:@"OrderTableViewCell"];
         [self.navigationItem setTitle:@"Order"];
    }
    self.btnCursorMap.hidden = YES;
    
    self.outerView.layer.cornerRadius=self.outerView.frame.size.width/2;
    self.contentView.layer.borderColor=[UIColor colorWithRed:252.0/255.0f green:125.0/255.0f blue:128.0/255.0f alpha:1.0].CGColor;
    self.contentView.layer.borderWidth=4.0f;
    self.contentView.layer.cornerRadius=self.contentView.frame.size.width/2;
    [self.contentView.layer setMasksToBounds:YES];
    
    self.viewTimer.layer.cornerRadius=self.viewTimer.frame.size.width/2;
    self.timerControl = [[DDHTimerControl alloc] initWithFrame:CGRectMake(0, 0, self.viewTimer.frame.size.width, self.viewTimer.frame.size.height)];
    [self.timerControl setMaxValue:[self.timerValue integerValue]];
    self.timerControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.timerControl setBackgroundColor:[UIColor clearColor]];
    [self.timerControl setType:DDHTimerTypeSolid];
    self.timerControl.color = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    self.timerControl.highlightColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    self.timerControl.minutesOrSeconds = self.timerValue.intValue;
    [self.timerControl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.viewTimer addSubview:self.timerControl];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:ORDER_STATUS] isEqualToString:@"Send"])
    {
        self.btnCursorMap.hidden = YES;
        [self callOfferdOrderWS];
    }
    else if([[[NSUserDefaults standardUserDefaults] objectForKey:INPROCESS] isEqualToString:@"2"])
    {
         self.btnCursorMap.hidden = NO;
         [self callPickUpWS];//For delivered.
    }
    else
    {
         self.btnCursorMap.hidden = NO;
        [self callAcceptedOrderWS];
    }
}

#pragma mark - Instance Methods

-(void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeTimer:) userInfo:nil repeats:YES];
    self.endDate = [NSDate dateWithTimeIntervalSinceNow:self.timerValue.intValue];
}

- (void)changeTimer:(NSTimer*)timer
{
    NSTimeInterval timeInterval = [self.endDate timeIntervalSinceNow];
    self.timerControl.minutesOrSeconds = ((NSInteger)timeInterval) % self.timerValue.intValue;
}

-(void)invalidateTimer
{
    if(self.timer != nil)
    {
        [self.timer invalidate];
    }
    
}
-(void)invalidateTimerRoute
{
    if(self.timerRoute != nil)
    {
        [self.timerRoute invalidate];
    }
}

- (void)valueChanged:(DDHTimerControl*)sender
{
    if(sender.minutesOrSeconds==0)
    {
        [self.timer invalidate];
        
        [self.objPopUp removeFromSuperview];
        self.objPopUp.frame = CGRectMake(0, 0, [GlobalManager getAppDelegateInstance].window.frame.size.width, [GlobalManager getAppDelegateInstance].window.frame.size.height);
        self.lblPopUpTitle.text = @"Bevy Driver";
        NSLog(@"Timer valuchanged");
        [[[GlobalManager getAppDelegateInstance] window] addSubview:self.objPopUp];
        self.objPopUp.hidden= self.popOk.hidden =self.lblPopUpTimeUp.hidden = NO;
        self.popNo.hidden = self.popYes.hidden = self.lblPopUpMesg.hidden = YES;
        [self.popOk addTarget:self action:@selector(btnClosePopupOkClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        self.objInner.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.objInner.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            self.objInner.transform = CGAffineTransformIdentity;
        }];
        
        [self performSelector:@selector(closePopUpAfterSometTime) withObject:nil afterDelay:6.0];
    }
}

-(void)closePopUpAfterSometTime
{
    [self btnClosePopupOkClicked:nil];
}
-(void)btnProfileClicked
{
    ProfileViewController *objProfil =[[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
    [self.navigationController pushViewController:objProfil animated:YES];
}

#pragma mark- IBActions Methods
/**
 * btnOrderClicked, This method is called when user clicks on order button.
 * Tapping on order tab it will display the orders Pick up Address of the store.
 * And it hides the order details tabel.
 */
-(IBAction)btnOrderClicked:(UIButton*)sender
{
    if(self.isFromProblem)
    {
        self.problemView.hidden = NO;
    }
    if([sender isSelected])
    {
        return;
    }
    [self.btnOder setSelected:YES];
    [self.btnOrderDetails setSelected:NO];
    [self.objTrans setHidden:NO];
    [self.tblOrder setHidden:NO];
    [self.tblOrderDetail setHidden:YES];
}

/**
 * btnOrderDetailsClicked, This method is called when user clicks on orderDetails button.
 * Tapping on order details tab it will display the order details which driver had received.
 * And it hides the order tabel.
 */
-(IBAction)btnOrderDetailsClicked:(UIButton*)sender
{
    if(self.isFromProblem)
    {
        self.problemView.hidden = YES;
    }
    if([sender isSelected])
    {
        return;
    }
    [self.btnOder setSelected:NO];
    [self.btnOrderDetails setSelected:YES];
    [self.objTrans setHidden:YES];
    [self.tblOrderDetail setHidden:NO];
    [self.tblOrder setHidden:YES];
}

/**
 * btnCursorMapClicked, This method is called when user clicks on customer Map button.
 * It navigates to the next screen - RouteDirection when user clicks on this button.
 * by checking the condition Accept or not
 */
-(IBAction)btnCursorMapClicked:(id)sender
{

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])
    {
        //"delivery_address
        NSString* url= @"";
        if (self.btnAccept.tag == 103){//Delivered
            url = [NSString stringWithFormat: @"comgooglemaps://?daddr=%@&directionsmode=driving",
                             [[self.dictAddressDetails objectForKey:@"delivery_address"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        else
        {
             url = [NSString stringWithFormat: @"comgooglemaps://?daddr=%@&directionsmode=driving",
                             [[self.dictAddressDetails objectForKey:@"pickup_address"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        }
        NSLog(@"URL --> %@",url);
       [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];

    }
    else
    {
        Class mapItemClass = [MKMapItem class];
        if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
        {
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([[self.dictAddressDetails objectForKey:(self.btnAccept.tag != 103) ? @"pickup_lat" : @"delivery_latitude"] floatValue],[[self.dictAddressDetails objectForKey:(self.btnAccept.tag != 103) ? @"pickup_long" : @"delivery_longitude"] floatValue]) addressDictionary:nil]];
            toLocation.name = [self.dictAddressDetails objectForKey:(self.btnAccept.tag != 103) ? @"pickup_address" :@"delivery_address"]; // set Location Name
            
            [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil]
                           launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
                                                                     forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
        }
    }
}

/**
 * btnDeclineClicked, This method is called when user clicks on decline button.
 * When user driver accept the order decline will changes to cancel order button.
 * and it navigates to the next screen - CancelOrder when user clicks on this button.
 */
-(IBAction)btnDeclineClicked:(id)sender
{
    if(self.btnDecline.tag==202)//Cancel order
    {
        CancelOrderViewController *objCanc =[[CancelOrderViewController alloc]initWithNibName:@"CancelOrderViewController" bundle:nil];
        [self.navigationController pushViewController:objCanc animated:YES];
    }
    else//Decline order
    {
        self.objPopUp.frame = CGRectMake(0, 0, [GlobalManager getAppDelegateInstance].window.frame.size.width, [GlobalManager getAppDelegateInstance].window.frame.size.height);
        self.lblPopUpTitle.text = @"Cancel Order";
        NSLog(@" Cancel order ");
        [[[GlobalManager getAppDelegateInstance] window] addSubview:self.objPopUp];
        self.popOk.hidden = self.lblPopUpTimeUp.hidden =self.lblPopUpMesg.hidden = YES;
        self.objPopUp.hidden=self.popNo.hidden = self.popYes.hidden = self.lblPopUpMesg.hidden = NO;
        [self.popNo addTarget:self action:@selector(btnClosePopupNoClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.popYes addTarget:self action:@selector(btnClosePopupYesClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        self.objInner.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
         {
             self.objInner.transform = CGAffineTransformIdentity;
         } completion:^(BOOL finished)
         {
             self.objInner.transform = CGAffineTransformIdentity;
         }];
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(self.objInner)
    {
        textField.enabled=NO;
        return NO;
    }
    else return YES;
}

/**
 * btnClosePopupOkClicked, This method is called when user clicks on ok button.
 * if given time is completed then popup will occured with text time out.
 * and redirects to home screen.
 */
-(IBAction)btnClosePopupOkClicked:(id)sender
{
    self.objInner.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        self.objInner.transform = CGAffineTransformMakeScale(0.01, 0.01);
    }
    completion:^(BOOL finished)
    {
        self.objPopUp.hidden = YES;
        self.objPopUp.transform = CGAffineTransformIdentity;
         NSLog(@"Order  DEclain");
        [self callTimeOutWS];
    }];
}

/**
 * btnClosePopupNoClicked, This method is called when user clicks on no button.
 * pop will be closed and  stay on same screen.
 */
-(IBAction)btnClosePopupNoClicked:(id)sender
{
    self.objInner.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.objInner.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        self.objPopUp.hidden = YES;
        self.objPopUp.transform = CGAffineTransformIdentity;
    }];
}

/**
 * btnClosePopupYesClicked, This method is called when user clicks on yes button.
 *  the order will be sent to another nearby driver, and redirects to previous page.
 */
-(IBAction)btnClosePopupYesClicked:(id)sender
{
    self.isRejected = YES;
    [self callResponseTheOrderWS];
}

/**
 * btnAcceptClicked, This method is called when user clicks on accept button.
 * user has to accept the order in one minute otherwise it redirects to home screen
  * when driver clicks on accept button timer will stop.
 * after accept it will calls the responseOrderWSor pickupWs
 */
-(IBAction)btnAcceptClicked:(id)sender
{
    if (self.btnAccept.tag==103)
    {
        if(self.timer != nil)
            [self.timer invalidate];
        if(self.isFromProblem)
        {
             if(self.objSignView.incrImage == nil)
            {
                [UIAlertView showWithTitle:APPNAME message:@"Please take signature" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [self.objSignView becomeFirstResponder];
                }];
            }
            else
            {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES];
                    [hud setLabelText:@"Please wait"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSelector:@selector(callConfirmationWS) withObject:nil afterDelay:0.1];
                });
            }
        }
        
        [self.lblDesc setHidden:YES];
        [self.outerView setHidden:YES];
        [self.btnCursorMap setHidden:NO];
        if(self.isFromProblem)
        {
            // need to do stuff
        }
        else{
            
            NSArray *arraySelected = [NSArray arrayWithArray:[self.arrOrderDetails valueForKey:@"isSelected"]];
            
            if ([arraySelected containsObject:@"NO"]) {
                [UIAlertView showWithTitle:APPNAME message:@"Please check all the items before delivery" handler:nil];
                return;
            }
            ConfirmationViewController *objConf =[[ConfirmationViewController alloc]initWithNibName:@"ConfirmationViewController" bundle:nil];
            objConf.dictAddressDetails = self.dictAddressDetails;
            [self.navigationController pushViewController:objConf animated:YES];
        }
    }
    else if(self.btnAccept.tag == 102)
    {
        if(self.timer != nil)
            [self.timer invalidate];
       
        [self.lblDesc setHidden:YES];
        [self.outerView setHidden:YES];
        [self.btnCursorMap setHidden:NO];
        NSArray *arraySelected = [NSArray arrayWithArray:[self.arrOrderDetails valueForKey:@"isSelected"]];
        
        if ([arraySelected containsObject:@"NO"]) {
            [UIAlertView showWithTitle:APPNAME message:@"Please check all the items before delivery" handler:nil];
            return;
        }
        [self callPickUpWS];
    }
    else
    {
         [self.btnCursorMap setHidden:YES];
        self.isRejected = NO;
        [self callResponseTheOrderWS];
    }
}

#pragma mark - UITableViewDataSource Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblOrder)
    {
        if (self.btnAccept.tag == 103)//Delivered
            return 2;
         else
            return 1;
    }
    else
    {
        return [self.arrOrderDetails count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblOrder)
    {
        if (self.isFromProblem)
        {
            ProblemWOrderTableViewCell *cell=[self.tblOrder dequeueReusableCellWithIdentifier:@"ProblemWOrderTableViewCell"];
            cell.btnSecondPhoneNumber.hidden = YES;
            
            if (self.btnAccept.tag == 103)//Delivered
            {
                if (indexPath.row==0)
                {
                    cell.lblPhoneNum.hidden = NO;
                    cell.lblPickUpAddress.text =[self.dictAddressDetails valueForKey:@"pickup_address"] ;
                    [cell.btnPhoneNumber setAttributedTitle:[self getAttrStringWithAge:@"Phone#         " :[self.dictAddressDetails valueForKey:@"store_phone"]] forState:UIControlStateNormal];
                    cell.btnSecondPhoneNumber.hidden = YES;
                    cell.lblAddressTitle.text = @"PICKUP ADDRESS";
                }
                else
                {
                    cell.btnSecondPhoneNumber.hidden = NO;
                    cell.lblPhoneNum.hidden = NO;
                    cell.lblPickUpAddress.text =[self.dictAddressDetails valueForKey:@"delivery_address"] ;
                    
                    // Need to show new number
                    [cell.btnPhoneNumber setAttributedTitle:[self getAttrStringWithAge:@"Phone#         " :[self.dictAddressDetails valueForKey:@"customer_phone"]] forState:UIControlStateNormal];
                    
                    
                    if (self.dictAddressDetails) {
                        NSString *strPhoneNumber = [NSString stringWithFormat:@", %@",[self.dictAddressDetails valueForKey:@"delivery_contact_number"]];
                        NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:strPhoneNumber];
                        
                        [commentString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [commentString length])];
//                        cell.btnSecondPhoneNumber.titleLabel.adjustsFontSizeToFitWidth = YES;
                        [cell.btnSecondPhoneNumber setAttributedTitle:commentString forState:UIControlStateNormal];
                        [cell.btnSecondPhoneNumber setTitleColor:[UIColor colorWithRed:63/255.0 green:91/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
                        
                        [cell.btnSecondPhoneNumber addTarget:self action:@selector(makeCallToCustomer:) forControlEvents:UIControlEventTouchUpInside];

                    }
                    NSString *strFirstPhoneNumber = [self.dictAddressDetails valueForKey:@"customer_phone"];
                    NSString *strSecondPhoneNumber = [self.dictAddressDetails valueForKey:@"delivery_contact_number"];
                    if ([strFirstPhoneNumber rangeOfString:strSecondPhoneNumber].location != NSNotFound)
                    {
                        cell.btnSecondPhoneNumber.hidden = YES;
                    }
                    else
                    {
                        cell.btnSecondPhoneNumber.hidden = NO;
                    }
                    
                    
//                    if ([[self.dictAddressDetails valueForKey:@"customer_phone"] isEqualToString:[self.dictAddressDetails valueForKey:@"delivery_contact_number"]]) {
//                        cell.btnSecondPhoneNumber.hidden = YES;
//                    }
                    cell.lblAddressTitle.text = @"DELIVERY ADDRESS";
                }
            }
            else
            {
                cell.lblAddressTitle.text = @"PICKUP ADDRESS";
                cell.lblPickUpAddress.text =[self.dictAddressDetails valueForKey:@"pickup_address"] ;
                [cell.btnPhoneNumber setAttributedTitle:[self getAttrStringWithAge:@"Phone#" :[self.dictAddressDetails valueForKey:@"customer_phone"]] forState:UIControlStateNormal];
                cell.lblPhoneNum.hidden = NO;
                if(![self.dictAddressDetails valueForKey:@"customer_phone"])
                {
                    cell.lblPhoneNum.hidden = YES;
                    [cell.btnPhoneNumber setAttributedTitle:[self getAttrStringWithAge:@"Phone#" :@""] forState:UIControlStateNormal];
                }
            }
            
            [cell.btnPhoneNumber addTarget:self action:@selector(makeCallToCustomer:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnPhoneNumber.tag = indexPath.row;
//            cell.lblPickUpAddress.adjustsFontSizeToFitWidth = YES;
            return cell;
        }
        else
        {
         OrderTableViewCell *cell=[self.tblOrder dequeueReusableCellWithIdentifier:@"OrderTableViewCell"];
            cell.btnSecondPhoneNumber.hidden = YES;
//            cell.lblPickUpAddress.adjustsFontSizeToFitWidth = YES;
            if (self.btnAccept.tag == 103)//Delivered
            {
                if (indexPath.row==0)
                {
                    cell.lblPhoneNum.hidden = NO;
                    cell.lblPickUpAddress.text =[self.dictAddressDetails valueForKey:@"pickup_address"] ;
                    [cell.btnPhoneNumber setAttributedTitle:[self getAttrStringWithAge:@"Phone#" :[self.dictAddressDetails valueForKey:@"store_phone"]] forState:UIControlStateNormal];
                    cell.lblAddressTitle.text = @"PICKUP ADDRESS";
                    cell.btnSecondPhoneNumber.hidden = YES;
//                    [cell.lblPickUpAddress sizeToFit];
                }
                else
                {
                    cell.lblPhoneNum.hidden = NO;
                    cell.lblPickUpAddress.text =[self.dictAddressDetails valueForKey:@"delivery_address"] ;
                    
                    // Need to show new number
                    cell.btnSecondPhoneNumber.hidden = NO;
                    [cell.btnPhoneNumber setAttributedTitle:[self getAttrStringWithAge:@"Phone#" :[self.dictAddressDetails valueForKey:@"customer_phone"]] forState:UIControlStateNormal];
                    
                    NSString *strPhoneNumber = [NSString stringWithFormat:@", %@",[self.dictAddressDetails valueForKey:@"delivery_contact_number"]];
                    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:strPhoneNumber];
                    
                    [commentString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [commentString length])];
                    [cell.btnSecondPhoneNumber setAttributedTitle:commentString forState:UIControlStateNormal];
                    
                    [cell.btnSecondPhoneNumber addTarget:self action:@selector(makeCallToCustomer:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [cell.btnSecondPhoneNumber setTitleColor:[UIColor colorWithRed:63/255.0 green:91/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];

                    cell.lblAddressTitle.text = @"DELIVERY ADDRESS";
                    
                    NSString *strFirstPhoneNumber = [self.dictAddressDetails valueForKey:@"customer_phone"];
                    NSString *strSecondPhoneNumber = [self.dictAddressDetails valueForKey:@"delivery_contact_number"];
                    if ([strFirstPhoneNumber rangeOfString:strSecondPhoneNumber].location != NSNotFound)
                    {
                        cell.btnSecondPhoneNumber.hidden = YES;
                    }
                    else
                    {
                        cell.btnSecondPhoneNumber.hidden = NO;
                    }
                    
//                    [cell.lblPickUpAddress sizeToFit];
//                    if ([[self.dictAddressDetails valueForKey:@"customer_phone"] isEqualToString:[self.dictAddressDetails valueForKey:@"delivery_contact_number"]]) {
//                        cell.btnSecondPhoneNumber.hidden = YES;
//                    }
//                    else
//                    {
//                        cell.btnSecondPhoneNumber.hidden = NO;
//                    }
                }
            }
            else
            {
                cell.lblAddressTitle.text = @"PICKUP ADDRESS";
                cell.lblPickUpAddress.text =[self.dictAddressDetails valueForKey:@"pickup_address"] ;
                [cell.btnPhoneNumber setAttributedTitle:[self getAttrStringWithAge:@"Phone#" :[self.dictAddressDetails valueForKey:@"customer_phone"]] forState:UIControlStateNormal];
                cell.lblPhoneNum.hidden = NO;
                if(![self.dictAddressDetails valueForKey:@"customer_phone"])
                {
                    cell.lblPhoneNum.hidden = YES;
                    [cell.btnPhoneNumber setAttributedTitle:[self getAttrStringWithAge:@"Phone#" :@""] forState:UIControlStateNormal];
                }
//                [cell.lblPickUpAddress sizeToFit];
            }
            
            [cell.btnPhoneNumber addTarget:self action:@selector(makeCallToCustomer:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnPhoneNumber.tag = indexPath.row;
//            cell.lblPickUpAddress.adjustsFontSizeToFitWidth = YES;
            return cell;
        }
    }
    else
    {
        OrderDetailTableViewCell *cell=[self.tblOrderDetail dequeueReusableCellWithIdentifier:@"OrderDetailTableViewCell"];
        NSMutableDictionary *dict = [self.arrOrderDetails objectAtIndex:indexPath.row];
        cell.lblPrductTitle.text =[dict valueForKey:@"product_name"];
        cell.lblSubTitle.text =[dict valueForKey:@"product_sub_title"];
        cell.lblPrice.text =[NSString stringWithFormat:@" £%@", [dict valueForKey:@"price"]];
        cell.lblQty.text =[dict valueForKey:@"qty"];
        [cell.imgProduct setImageWithContentsOfURL:[NSURL URLWithString:[dict objectForKey:@"product_image"]] placeholderImage:[UIImage imageNamed:@"listview_placeholder"]];
        
        cell.lblTag.text = ([[dict valueForKey:@"product_tag"] length])?[dict valueForKey:@"product_tag"]:@"---";
        if (self.isFromProblem) {
            cell.btnCheck.hidden = YES;
        }
        else
        {
            cell.btnCheck.hidden = NO;
        }
        
        if ([[[self.arrOrderDetails objectAtIndex:indexPath.row] valueForKey:@"isSelected"] isEqualToString:@"NO"]) {
            [cell.btnCheck setSelected:NO];
        }
        else
        {
            [cell.btnCheck setSelected:YES];
        }
        
        if (isPickUp) {
            cell.btnCheck.hidden = YES;
        }
        else
        {
            cell.btnCheck.hidden = NO;
        }
        cell.btnCheck.tag = indexPath.row;
        [cell.btnCheck addTarget:self action:@selector(btnCheckItem:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
}

-(void)btnCheckItem:(UIButton*)sender
{
    sender.selected = !sender.selected;
    NSMutableDictionary *dictData = [[self.arrOrderDetails objectAtIndex:sender.tag] mutableCopy];
    [dictData setValue:(sender.selected)?@"YES":@"NO" forKey:@"isSelected"];
    [self.arrOrderDetails replaceObjectAtIndex:sender.tag withObject:dictData];
    [self.tblOrderDetail reloadData];
}

-(NSAttributedString*)getAttrStringWithAge : (NSString *)str1 :(NSString*)str2{
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",str1,str2]];
    UIFont *fontReg=[UIFont fontWithName:@"OpenSans" size:13];
    UIFont *fontMed=[UIFont fontWithName:@"OpenSans" size:13];
    NSDictionary *attrsReg = @{ NSFontAttributeName : fontReg,NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                NSForegroundColorAttributeName : [UIColor colorWithRed:63/255.0 green:91/255.0 blue:255/255.0 alpha:1]};
    
    NSDictionary *attrsMed = @{ NSFontAttributeName : fontMed,
                                NSForegroundColorAttributeName : [UIColor colorWithRed:63/255.0 green:63/255.0 blue:63/255.0 alpha:1] };
    
    [attString addAttributes:attrsMed range:NSMakeRange(0, str1.length)];
    [attString addAttributes:attrsReg range:NSMakeRange(str1.length+1, str2.length)];
    return attString;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isFromProblem)
    {
        return 77;
    }
    return (tableView == self.tblOrderDetail)?80:100;
}

-(void)makeCallToCustomer:(UIButton*)sender
{
    NSString *strPhoneNumber = @"";

    
    if (sender.tag >= 100) {
        strPhoneNumber = [self.dictAddressDetails valueForKey:@"delivery_contact_number"];
    }
    else {
        strPhoneNumber = (sender.tag == 0)?[self.dictAddressDetails valueForKey:(self.btnAccept.tag == 103)?@"store_phone":@"customer_phone"]:[self.dictAddressDetails valueForKey:@"customer_phone"];
    }
    
    [UIAlertView showConfirmationDialogWithTitle:[NSString stringWithFormat:@"Call : %@",strPhoneNumber] message:nil firstButtonTitle:@"Cancel" secondButtonTitle:@"Ok" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if(buttonIndex==1)
        {
            @autoreleasepool
            {
                NSURL *target = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"tel:%@", strPhoneNumber]];
                [[UIApplication sharedApplication] openURL:target];
            }
        }
    }];
    
    
}

#pragma mark- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - WS calling methods
-(void)callConfirmationWS
{
//    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] forKey:@"driver_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:ORDER_ID] forKey:@"order_id"];
    [self.objWSHelper setServiceName:@"Confirmation"];
    
    NSData *imageData =  UIImagePNGRepresentation(self.objSignView.incrImage);
    [self.objWSHelper sendRequestWithPostURL:[WS_Urls getConfirmTheOrderURL:params] andParametrers:nil andData:imageData andFileKey:@"customer_signature_image" andExtention:@"png" andMymeTye:@"image/png"];
}
-(void)callOfferdOrderWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:DRIVER_ID]  forKey:@"driver_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:ORDER_ID]  forKey:@"order_id"];
    self.objWSHelper.serviceName = @"OFFERED_ORDER";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getOfferedOrderListURL:params]];
}

-(void)callAcceptedOrderWS
{
    if(self.timer != nil)
        [self.timer invalidate];
    [self.lblDesc setHidden:YES];
    [self.outerView setHidden:YES];
    [self.btnCursorMap setHidden:NO];
    
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:DRIVER_ID]  forKey:@"driver_id"];
    self.objWSHelper.serviceName = @"AcceptedOrder";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getAcceptedOrdersURL:params]];
}


-(void)callTimeOutWS
{
    
    
    
    
    NSLog(@"crash found here");
    NSLog(@"Driver ID:  %@",[[NSUserDefaults standardUserDefaults] valueForKey:DRIVER_ID]);
    NSLog(@"Dict Details :%@",self.dictAddressDetails);
    
    if (self.dictAddressDetails)
    {
        [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:DRIVER_ID]  forKey:@"driver_id"];
        [params setObject:[self.dictAddressDetails valueForKey:@"order_request_id"]  forKey:@"order_request_id"];
        [params setObject:@"NotRespond" forKey:@"driver_responce"];//  previous value === "Accept"
        self.objWSHelper.serviceName = @"TIME_OUT";
        [self.objWSHelper sendRequestWithURL:[WS_Urls getResponseTheOrderURL:params]];
    }
    else
    {
        for (UIViewController *objVC in [GlobalManager getAppDelegateInstance].objNavController.viewControllers)
        {
            if ([objVC isKindOfClass:[HomeViewController class]])
            {
                NSLog(@"Driver cancel");
                [[GlobalManager getAppDelegateInstance].objNavController popToViewController:objVC animated:YES];
                break;
            }
        }
    }
    
//    isAccepted = YES;
    
}

-(void)callResponseTheOrderWS
{
    isAccepted = YES;
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:DRIVER_ID]  forKey:@"driver_id"];
    [params setObject:[self.dictAddressDetails valueForKey:@"order_request_id"]  forKey:@"order_request_id"];
    [params setObject:(self.isRejected ? @"Rejected" : @"Packaged") forKey:@"driver_responce"];//  previous value === "Accept"
    self.objWSHelper.serviceName = @"RESPONSE_THE_ORDER";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getResponseTheOrderURL:params]];
}

-(void)callPickUpWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:DRIVER_ID]  forKey:@"driver_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:ORDER_ID]  forKey:@"order_id"];
    self.objWSHelper.serviceName = @"PickUp";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getPickUpTheOredersURL:params]];
}

-(void)callAddRouteWS
{
    if([[NSUserDefaults standardUserDefaults] valueForKey:ORDER_ID])
    {
        if(self.isFirstTime)
            [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] forKey:@"driver_id"];
        [params setObject:([[NSUserDefaults standardUserDefaults] valueForKey:ORDER_ID])?[[NSUserDefaults standardUserDefaults] valueForKey:ORDER_ID]:@"" forKey:@"order_id"];
        [params setObject:[[NSUserDefaults standardUserDefaults]valueForKey:LATITUDE]  forKey:@"latitude"];
        [params setObject:[[NSUserDefaults standardUserDefaults]valueForKey:LONGITUDE]  forKey:@"longitude"];
        
        NSLog(@"Sending:-\nLatitude:-%@--- Longitude:-%@",[[NSUserDefaults standardUserDefaults]valueForKey:LATITUDE],[[NSUserDefaults standardUserDefaults]valueForKey:LONGITUDE]);
        
         self.objWSHelper.serviceName = @"routeMap";
        [self.objWSHelper sendRequestWithURL:[WS_Urls getAddRoutDetailsURL:params]];
    }
}


-(void)footerViewForTableOrders
{
    CGRect footerRect = CGRectMake(0, 0, self.tblOrder.frame.size.width, 100);
    UIView *viewFooter = [[UIView alloc] initWithFrame:footerRect];
    viewFooter.backgroundColor = [self.tblOrder backgroundColor];
    UILabel *lblDeleveryNote = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 200, 25)];
    
    lblDeleveryNote.text = @"Delivery Note";
    
    lblDeleveryNote.font = [UIFont fontWithName:@"OpenSans" size:15];
    UILabel *lblDescription = [[UILabel alloc] init];
    lblDescription.textColor = [UIColor colorWithRed:63.0/255.0 green:63.0/255.0 blue:63.0/255.0 alpha:1.0];
    lblDescription.backgroundColor = [self.tblOrder backgroundColor];
    
    [viewFooter addSubview:lblDeleveryNote];
    [viewFooter addSubview:lblDescription];
    lblDescription.font = [UIFont fontWithName:@"OpenSans-Light" size:13];
    
    int height = [self heightForText:[self.dictAddressDetails  objectForKey:@"delivery_note"] width:self.tblOrder.frame.size.width-30 font:[UIFont fontWithName:@"OpenSans-Light" size:13] lineBreakMode:NSLineBreakByWordWrapping];
    
    if (height>80) {
        lblDescription.frame = CGRectMake(20, 23, self.tblOrder.frame.size.width-30, 90);
    }
    else
    {
        lblDescription.frame = CGRectMake(20, 23, self.tblOrder.frame.size.width-30, height);
    }
    
    lblDescription.text = [self.dictAddressDetails  objectForKey:@"delivery_note"];
    lblDescription.numberOfLines = 0;
    lblDescription.adjustsFontSizeToFitWidth = YES;
    if ([[self.dictAddressDetails  objectForKey:@"delivery_note"] length]) {
       self.tblOrder.tableFooterView = viewFooter;
    }
}

-(int)heightForText:(NSString *)str width:(int)width font:(UIFont *)font lineBreakMode:(NSLineBreakMode) lineBreakMode
{
    CGSize textSize;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        textSize = [str boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
    } else {
        textSize = [str sizeWithFont:font constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:lineBreakMode];
    }
    return textSize.height+5;
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
    
    if ([helper.serviceName isEqualToString:@"RESPONSE_THE_ORDER"])
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            isAccepted = YES;
            if(self.isRejected)
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:ORDER_STATUS];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ORDER_ID];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.timer invalidate];
                self.objInner.transform = CGAffineTransformIdentity;
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
                {
                    self.objInner.transform = CGAffineTransformMakeScale(0.01, 0.01);
                }
                completion:^(BOOL finished)
                {
                    self.objPopUp.hidden = YES;
                    self.objPopUp.transform = CGAffineTransformIdentity;
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
            else
            {
                if(self.timer != nil)
                    [self.timer invalidate];
                [self.lblDesc setHidden:YES];
                [self.outerView setHidden:YES];
                [self.btnCursorMap setHidden:NO];
                
                [self callAcceptedOrderWS];
                
            }
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
    else if([helper.serviceName isEqualToString:@"Confirmation"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:DRIVER_ONLINE_STATUS];
        if([[dictResults objectForKey:@"data"] count])
        {
            
            if([[[[dictResults objectForKey:@"data"] lastObject] objectForKey:@"iRoughtId"]length]>0)
            {
                
//                [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex)
//                 {
//                     if (self.isFromProblem) {
//                         
//                     }
//                     [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:ORDER_STATUS];
//                     [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ORDER_ID];
//                     [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:INPROCESS];
//                     [[NSUserDefaults standardUserDefaults] synchronize];
//                     
//                     for (UIViewController *objVC in [GlobalManager getAppDelegateInstance].objNavController.viewControllers)
//                     {
//                         if([objVC isKindOfClass:[OrderViewController class]] && !self.isFromProblem)
//                         {
//                             OrderViewController *viewController = (OrderViewController *)objVC;
//                             [viewController invalidateTimerRoute];
//                             break;
//                         }
//                         
//                         if ([objVC isKindOfClass:[HomeViewController class]])
//                         {
//                             [[GlobalManager getAppDelegateInstance].objNavController popToViewController:objVC animated:YES];
//                             break;
//                         }
//                     }
//                 }];
                
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   //main thread;
                                   self.isFirstTime = NO;
                               });
                return;
            }
        }
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex)
             {
                 if (self.isFromProblem) {
                     
                 }
                 [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:ORDER_STATUS];
                 [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ORDER_ID];
                 [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:INPROCESS];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 for (UIViewController *objVC in [GlobalManager getAppDelegateInstance].objNavController.viewControllers)
                 {
                     if([objVC isKindOfClass:[OrderViewController class]] && !self.isFromProblem)
                     {
                         OrderViewController *viewController = (OrderViewController *)objVC;
                         [viewController invalidateTimerRoute];
                         break;
                     }
                     
                     if ([objVC isKindOfClass:[HomeViewController class]])
                     {
                         [[GlobalManager getAppDelegateInstance].objNavController popToViewController:objVC animated:YES];
                         break;
                     }
                 }
             }];
        }
    }
    else if([helper.serviceName isEqualToString:@"OFFERED_ORDER"])
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            [self.outerView setHidden:NO];
            [self.lblDesc setHidden:NO];
            [self.btnCursorMap setHidden:YES];
            self.arrOrderDetails = [[NSMutableArray arrayWithArray:[[[dictResults objectForKey:@"data"] objectAtIndex:0] valueForKey:@"order_details"]] mutableCopy];
            
            isPickUp = YES;
            for (int i =0 ; i<self.arrOrderDetails.count; i++) {
                NSMutableDictionary *dictData = [[self.arrOrderDetails objectAtIndex:i] mutableCopy];
                [dictData setValue:@"NO" forKey:@"isSelected"];
                [self.arrOrderDetails replaceObjectAtIndex:i withObject:dictData];
            }
            self.dictAddressDetails = [[dictResults objectForKey:@"data"] objectAtIndex:0];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:INPROCESS];
            [[NSUserDefaults standardUserDefaults] setObject:[self.dictAddressDetails valueForKey:@"order_id"] forKey:ORDER_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [GlobalManager getAppDelegateInstance].strTransaction = [self.dictAddressDetails valueForKey:@"transaction_no"];
            self.lblAmnt.text = [GlobalManager getAppDelegateInstance].strTransaction;
            [self.lblDesc setText:[self.dictAddressDetails objectForKey:@"message"]];
            [GlobalManager getAppDelegateInstance].strPickUpInProcess =@"YES";
           
            self.timerValue = [self.dictAddressDetails objectForKey:@"remaining_seconds"];
            
            if ([self.timerValue integerValue] > [[[[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_SETTINGS] objectForKey:@"max_order_response_time"] integerValue]) {
                self.timerValue = [[[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_SETTINGS] objectForKey:@"max_order_response_time"];
            }
            [self footerViewForTableOrders];
            
            NSLog(@"%@",[self.dictAddressDetails objectForKey:@"remaining_seconds"]);
            self.timerControl.minutesOrSeconds = self.timerValue.intValue-1;
            [self performSelector:@selector(startTimer) withObject:nil afterDelay:1.0];
            
            [self.tblOrder reloadData];
            [self.tblOrderDetail reloadData];
        }
        else
        {
            if(self.timer != nil)
                [self.timer invalidate];
            
            [self.objPopUp removeFromSuperview];
            self.objPopUp.frame = CGRectMake(0, 0, [GlobalManager getAppDelegateInstance].window.frame.size.width, [GlobalManager getAppDelegateInstance].window.frame.size.height);
            self.lblPopUpTitle.text = @"Bevy Driver";
            NSLog(@"bevy driver");
            [[[GlobalManager getAppDelegateInstance] window] addSubview:self.objPopUp];
            self.objPopUp.hidden= self.popOk.hidden =self.lblPopUpTimeUp.hidden = NO;
            self.popNo.hidden = self.popYes.hidden = self.lblPopUpMesg.hidden = YES;
            [self.popOk addTarget:self action:@selector(btnClosePopupOkClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            self.objInner.transform = CGAffineTransformMakeScale(0.01, 0.01);
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                self.objInner.transform = CGAffineTransformIdentity;
            }
            completion:^(BOOL finished)
            {
                self.objInner.transform = CGAffineTransformIdentity;
            }];
            
            return;
        }
    }
    else if([helper.serviceName isEqualToString:@"AcceptedOrder"])
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            isAccepted = YES;
            self.arrOrderDetails = [[NSMutableArray arrayWithArray:[[[dictResults objectForKey:@"data"] objectAtIndex:0] valueForKey:@"order_details"] ] mutableCopy];
            
            isPickUp = NO;
            [self btnOrderDetailsClicked:self.btnOrderDetails];
            for (int i =0 ; i<self.arrOrderDetails.count; i++) {
                NSMutableDictionary *dictData = [[self.arrOrderDetails objectAtIndex:i] mutableCopy];
                [dictData setValue:@"NO" forKey:@"isSelected"];
                [self.arrOrderDetails replaceObjectAtIndex:i withObject:dictData];
            }
            self.dictAddressDetails = [[dictResults objectForKey:@"data"] objectAtIndex:0];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"Accept" forKey:ORDER_STATUS ];
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:INPROCESS];
            [[NSUserDefaults standardUserDefaults] setObject:[self.dictAddressDetails valueForKey:@"order_id"] forKey:ORDER_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self footerViewForTableOrders];
            [GlobalManager getAppDelegateInstance].strTransaction = [self.dictAddressDetails valueForKey:@"transaction_no"];
            self.lblAmnt.text = [GlobalManager getAppDelegateInstance].strTransaction;
            [GlobalManager getAppDelegateInstance].strPickUpInProcess =@"YES";
            
            self.btnAccept.tag = 102;
            self.btnDecline.tag = 202;
            [self.btnAccept setImage:[UIImage imageNamed:@"pickedup"] forState:UIControlStateNormal];
            [self.btnDecline setImage:[UIImage imageNamed:@"cancel-order"] forState:UIControlStateNormal];
            
            [self.tblOrder reloadData];
            [self.tblOrderDetail reloadData];
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex)
             {
                 [self.navigationController popViewControllerAnimated:YES];
             }];
            return;
        }
    }
    else if ([helper.serviceName isEqualToString:@"PickUp"])
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            self.arrOrderDetails = [NSMutableArray arrayWithArray:[[[[dictResults objectForKey:@"data"] objectAtIndex:0] valueForKey:@"order_details"] mutableCopy]];
            
            isPickUp = YES;
            
            for (int i =0 ; i<self.arrOrderDetails.count; i++) {
                NSMutableDictionary *dictData = [[self.arrOrderDetails objectAtIndex:i] mutableCopy];
                [dictData setValue:@"YES" forKey:@"isSelected"];
                [self.arrOrderDetails replaceObjectAtIndex:i withObject:dictData];
            }
            [self btnOrderClicked:self.btnOder];
            
            self.dictAddressDetails = [NSDictionary dictionaryWithDictionary:[[dictResults objectForKey:@"data"] objectAtIndex:0]];
            [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:INPROCESS];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [GlobalManager getAppDelegateInstance].strTransaction = [self.dictAddressDetails valueForKey:@"transaction_no"];
            self.lblAmnt.text = [GlobalManager getAppDelegateInstance].strTransaction;
            
            if(self.timer != nil)
                [self.timer invalidate];
            [self.lblDesc setHidden:YES];
            [self.outerView setHidden:YES];
            [self.btnCursorMap setHidden:NO];
            self.btnAccept.tag = 103;
           // if(self.isFromProblem)
            [self.btnAccept setImage:[UIImage imageNamed:((self.isFromProblem)?@"problem_btn":@"delivered")] forState:UIControlStateNormal];
            self.btnDecline.tag = 202;
            [self.btnDecline setImage:[UIImage imageNamed:((self.isFromProblem)?@"cancel-order":@"cancel-order")] forState:UIControlStateNormal];
            [self footerViewForTableOrders];
            if (self.isFromProblem) {
                self.btnDecline.hidden = YES;
                int xPosition = ([GlobalManager getAppDelegateInstance].window.frame.size.width - self.btnAccept.frame.size.width)/2;
                self.btnAccept.frame = CGRectMake(xPosition, self.btnAccept.frame.origin.y, self.btnAccept.frame.size.width, self.btnAccept.frame.size.height);
            }
            
            [self.tblOrder reloadData];
             [self.tblOrderDetail reloadData];
            
            self.driverLocation = [[CLLocation alloc] initWithLatitude:[GlobalManager getAppDelegateInstance].currentLocation.coordinate.latitude longitude:[GlobalManager getAppDelegateInstance].currentLocation.coordinate.longitude];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [self callAddRouteWS];
            });
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^
                           {
                               //Background;
                               dispatch_async(dispatch_get_main_queue(), ^
                                              {
                                                  //main thread;
                                                  if(self.timerRoute != nil)
                                                  {
                                                      [self.timerRoute invalidate];
                                                  }
                                                  self.timerRoute = [NSTimer scheduledTimerWithTimeInterval:SECONDS target:self selector:@selector(callAddRouteWS) userInfo:nil repeats:YES];
                                                  [[NSRunLoop mainRunLoop] addTimer:self.timerRoute forMode:NSDefaultRunLoopMode];
                                              });
                           });
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
    else if ([helper.serviceName isEqualToString:@"routeMap"])
    {
        if([[dictResults objectForKey:@"data"] count])
        {
            
             if([[[[dictResults objectForKey:@"data"] lastObject] objectForKey:@"api_name"] isEqualToString:@"confirm_the_order"])
             {
                 [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                  {
                      if (self.isFromProblem) {
                          
                      }
                      [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:ORDER_STATUS];
                      [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ORDER_ID];
                      [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:INPROCESS];
                      [[NSUserDefaults standardUserDefaults] synchronize];
                      
                      for (UIViewController *objVC in [GlobalManager getAppDelegateInstance].objNavController.viewControllers)
                      {
                          if([objVC isKindOfClass:[OrderViewController class]] && !self.isFromProblem)
                          {
                              OrderViewController *viewController = (OrderViewController *)objVC;
                              [viewController invalidateTimerRoute];
                              break;
                          }
                          
                          if ([objVC isKindOfClass:[HomeViewController class]])
                          {
                              [[GlobalManager getAppDelegateInstance].objNavController popToViewController:objVC animated:YES];
                              break;
                          }
                      }
                  }];
                 

             
             }
          
        }
        
    if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
    {
        NSLog(@"SUCCESS");
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           //main thread;
                                                  self.isFirstTime = NO;
                       });
    }
    else
    {
        NSLog(@"FAILURE");
    }
    }
    else if ([helper.serviceName isEqualToString:@"TIME_OUT"])
    {
        for (UIViewController *objVC in [GlobalManager getAppDelegateInstance].objNavController.viewControllers)
        {
            if ([objVC isKindOfClass:[HomeViewController class]])
            {
                NSLog(@"Driver cancel");
                [[GlobalManager getAppDelegateInstance].objNavController popToViewController:objVC animated:YES];
                break;
            }
        }
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    [GlobalManager showDidFailError:error];
}

@end