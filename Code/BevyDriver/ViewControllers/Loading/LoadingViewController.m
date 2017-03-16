//
//  LoadingViewController.m
//  Bevy
//
//  Created by CompanyName on 20/12/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "LoadingViewController.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "OrderViewController.h"
#import "ConfirmationViewController.h"

@interface LoadingViewController ()

@end

@implementation LoadingViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *strImageName = @"Default";
    if (iPhoneType>480) {
        strImageName = [strImageName stringByAppendingFormat:@"-%.fh.png",iPhoneType];
    }
    else{
        strImageName = [strImageName stringByAppendingFormat:@".png"];
    }
    [self.imageBg setImage:[UIImage imageNamed:strImageName]];
    self.objWSHelper = [[WS_Helper alloc] init];
    [self.objWSHelper setTarget:self];
    [self.actIndicator startAnimating];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self callApplicationSettingsWS];
}

#pragma mark - Instance Methods

-(void)launchLoginViewController
{
    [self.actIndicator stopAnimating];
    NSDictionary *dictAppSettings = [[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_SETTINGS];
    NSInteger orderResponseTime = [[dictAppSettings objectForKey:@"max_order_response_time"] integerValue]-1;

    LoginViewController *objLoginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    HomeViewController *objHomeVC = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    OrderViewController *objOrderVC = [[OrderViewController alloc] initWithNibName:@"OrderViewController" bundle:nil];
    [objOrderVC setTimerValue:[NSString stringWithFormat:@"%li", (long)orderResponseTime]];
   
    if ([[NSUserDefaults standardUserDefaults] boolForKey:AUTO_LOGIN])
    {
        NSString *orderStatus = [[NSUserDefaults standardUserDefaults] objectForKey:ORDER_STATUS];
        if ([orderStatus isEqualToString:@""])
            [self.navigationController setViewControllers:@[objLoginVC, objHomeVC] animated:YES];
        else
            [self.navigationController setViewControllers:@[objLoginVC, objHomeVC, objOrderVC] animated:YES];
    }
    else
    {
        [self.navigationController pushViewController:objLoginVC animated:YES];
    }
}

#pragma mark - Webservice Methods
-(void)callApplicationSettingsWS
{
    [self.objWSHelper setServiceName:@"APPLICATION_SETTINGS"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getApplicationSettingsURL:nil]];
}

-(void)callDriverStatusWS
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID]  forKey:@"driver_id"];
    self.objWSHelper.serviceName = @"DRIVERSTATUS";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getDriverStatusURL:params]];
}

#pragma mark - ParseWSDelegate Methods
-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    if(!response)
        return;
    NSDictionary *responseDictionary = [NSDictionary dictionaryWithDictionary:response];
    if([helper.serviceName isEqualToString:@"APPLICATION_SETTINGS"])
    {
        if([[[responseDictionary objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            NSDictionary *dictSupport = [NSDictionary dictionaryWithDictionary:[[responseDictionary objectForKey:@"data"] objectForKey:@"app_settings"]];
            [[NSUserDefaults standardUserDefaults] setObject:dictSupport forKey:APPLICATION_SETTINGS];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:APPLICATION_SETTINGS];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        if(!self.isNotificationFired)
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:AUTO_LOGIN])
                [self callDriverStatusWS];
            else
                [self launchLoginViewController];
        }
        else
            return;
    }
    else if ([helper.serviceName isEqualToString:@"DRIVERSTATUS"])
    {
        if([[[responseDictionary objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:[[[responseDictionary objectForKey:@"data"] objectAtIndex:0] objectForKey:@"order_status"] forKey:ORDER_STATUS];
            [[NSUserDefaults standardUserDefaults] setObject:[[[responseDictionary objectForKey:@"data"] objectAtIndex:0] objectForKey:@"order_id"] forKey:ORDER_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:[[[responseDictionary objectForKey:@"data"] objectAtIndex:0] objectForKey:DRIVER_ONLINE_STATUS] forKey:DRIVER_ONLINE_STATUS];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:ORDER_STATUS];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ORDER_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [self launchLoginViewController];
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:APPLICATION_SETTINGS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
