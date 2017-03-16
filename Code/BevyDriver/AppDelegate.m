//
//  AppDelegate.m
//  BevyDriver
//
//  Created by CompanyName on 1/2/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import "AppDelegate.h"
#import "LoadingViewController.h"
#import "Reachability.h"
#import "OrderViewController.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "UIAlertView+Blocks.h"
#import "Crittercism.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    LoadingViewController *objLoadingVC = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
    self.objNavController = [[UINavigationController alloc] initWithRootViewController:objLoadingVC];
    self.objNavController.navigationBar.translucent = NO;
    self.objNavController.navigationBarHidden = YES;
    [self setApperenceSetUp];
    
    self.appInBackGround = NO;
    
    self.stopLocationUpdate = NO;
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [Crittercism enableWithAppID:@"560f8448d224ac0a00ed3f10"];
    
    [self setApplicationSettings];
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    self.locationManager.distanceFilter = kCLLocationAccuracyBestForNavigation;
    #ifdef __IPHONE_8_0
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        {
            [self.locationManager requestWhenInUseAuthorization];
        }
    #endif
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0"))
    {
        if ([self.locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
            [self.locationManager setAllowsBackgroundLocationUpdates:YES];
        }
    }
    
    [self.locationManager startUpdatingLocation];
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [application registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    if (launchOptions != nil)
    {
        
        UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (localNotif) {
            if([[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] length]!=0){
                [objLoadingVC setIsNotificationFired:YES];
                NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
                NSLog(@"LAUNCH DETAILS: %@", dictionary);
                [self handleRemoteNotification:dictionary];
            }
        }
        
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] length]) {
        NSLog(@"Badge count --> %i",(int)[UIApplication sharedApplication].applicationIconBadgeNumber);
        if([UIApplication sharedApplication].applicationIconBadgeNumber > 0)
        {
            NSLog(@"Badge Count is there...");
            [self callDriverNotificationCheckWS];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        }
        else
        {
            [self callDriverLocationWS];
        }
    }
    self.window.rootViewController = self.objNavController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
//    [self.locationManager stopUpdatingLocation];
//    if([[NSUserDefaults standardUserDefaults] objectForKey:ORDER_ID] != nil)
//    {
    self.appInBackGround = YES;
        if ([CLLocationManager significantLocationChangeMonitoringAvailable])
            [self.locationManager startMonitoringSignificantLocationChanges];
//    }
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    self.appInBackGround = NO;
    if([[NSUserDefaults standardUserDefaults] objectForKey:ORDER_ID] != nil)
    {
        if ([CLLocationManager significantLocationChangeMonitoringAvailable])
            [self.locationManager stopMonitoringSignificantLocationChanges];
    }
    [self.locationManager startUpdatingLocation];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] length]) {
        NSLog(@"Badge count --> %i",(int)[UIApplication sharedApplication].applicationIconBadgeNumber);
        if([UIApplication sharedApplication].applicationIconBadgeNumber > 0)
        {
            NSLog(@"Badge Count is there...");
            [self callDriverNotificationCheckWS];
        }
        else
        {
            [self callDriverLocationWS];
        }
    }
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - AppSettings methods

-(void)setApperenceSetUp
{
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)])
    {
        [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:-2 forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundImage:[GlobalManager imageWithColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
        [[UINavigationBar appearance] setShadowImage:[UIImage new]];
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0],
          NSForegroundColorAttributeName,[GlobalManager fontMuseoSans300:22.0],NSFontAttributeName,nil]];
        [[UINavigationBar appearance] setTintColor:[UIColor clearColor]];
    }
}

-(void)setApplicationSettings
{
    //Clear ORDER_STATUS and ORDER_ID because we are calling at notification time, loading, login;
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:ORDER_STATUS];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ORDER_ID];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:AUTO_LOGIN])
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:AUTO_LOGIN];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:INPROCESS]==nil)
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:INPROCESS];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN]==nil)
        [[NSUserDefaults standardUserDefaults] setObject:@"123" forKey:DEVICE_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setCustomLocationDelegate:(id<CustomLocationManagerDelegate>)locationDelegate
{
    NSLog(@"setLocationDelegate");
    if(self.locationDelegate != nil)
        self.locationDelegate = nil;
    self.locationDelegate = locationDelegate;
}

-(MKMapView *)getMapViewInstance
{
    if(self.mapView == nil);
    {
        self.mapView = [[MKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self.mapView setOpaque:YES];
        [self.mapView setClipsToBounds:YES];
    }
    [self.mapView setDelegate:nil];
    [self.mapView removeFromSuperview];
    return self.mapView;
}

#pragma mark - Push Notification Methods

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
//    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", deviceToken);
    NSString* newDeviceToken = [[[[deviceToken description]
                                  stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                 stringByReplacingOccurrencesOfString: @">" withString: @""]
                                stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"DEVICE TOKEN: %@",newDeviceToken);
    
    if ([newDeviceToken length]) {
        [[NSUserDefaults standardUserDefaults] setObject:newDeviceToken forKey:DEVICE_TOKEN];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"123" forKey:DEVICE_TOKEN];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    [[NSUserDefaults standardUserDefaults] setObject:@"123" forKey:DEVICE_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    NSLog(@"didReceiveRemoteNotification: %@", userInfo);
    if (application.applicationState == UIApplicationStateActive) {
        [self handleRemoteNotification:userInfo];
    }
    else {
    }
}

-(void)handleRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"handleRemoteNotification: %@", userInfo);
    self.dictUserInfo = [NSDictionary dictionaryWithDictionary:userInfo];
    self.appInBackGround = NO;
    @try {
        [UIAlertView showWithTitle:APPNAME message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] handler:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             NSString *strNotificationType = [[[userInfo objectForKey:@"aps"] objectForKey:@"otherparam"] valueForKey:@"notificationtype"];
             if ([strNotificationType isEqualToString:@"ORDERUPDATED"])
             {
                 //To refresh Order details.
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"Reload_Order_Details" object:nil];
             }
             
             else if ([strNotificationType isEqualToString:@"ORDERDELIVERED"] || [strNotificationType isEqualToString:@"CANCELLEDORDER"])
             {
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
             }
             else{
                 [self callDriverStatusWS];
             }
             
             return;
         }];
    }
    @catch (NSException *exception) {

    }
    @finally {

    }
}

-(void)showAlertAfterPust:(NSString *)message
{
    [UIAlertView showWithTitle:APPNAME message:message handler:nil];
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"])
    {
    }
    else if ([identifier isEqualToString:@"answerAction"])
    {
    }
}
#endif

#pragma mark - Back Ground Fetching.
-(void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] length]) {
        return;
    }
    
    NSLog(@"Background fetch started...");
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID]  forKey:@"driver_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults]valueForKey:LATITUDE]  forKey:@"latitude"];
    [params setObject:[[NSUserDefaults standardUserDefaults]valueForKey:LONGITUDE]  forKey:@"longitude"];
    
    NSString *urlString = [NSString stringWithFormat:
                           [WS_Urls getDriverLocationURL:params],
                           [[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID],[[NSUserDefaults standardUserDefaults]valueForKey:LATITUDE],[[NSUserDefaults standardUserDefaults]valueForKey:LONGITUDE]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:urlString]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                if (!error && httpResp.statusCode == 200) {
                    //---print out the result obtained---
                    NSString *result =
                    [[NSString alloc] initWithBytes:[data bytes]
                                             length:[data length]
                                           encoding:NSUTF8StringEncoding];
                    NSLog(@"%@", result);
                    
                    
                    completionHandler(UIBackgroundFetchResultNewData);
                    NSLog(@"Background fetch completed...");
                } else {
                    NSLog(@"%@", error.description);
                    completionHandler(UIBackgroundFetchResultFailed);
                    NSLog(@"Background fetch Failed...");
                }
            }
      ] resume
     ];
    
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    [defaluts setObject:@"51.519522" forKey:LATITUDE];
    [defaluts setObject:@"-0.211258" forKey:LONGITUDE];
    [defaluts synchronize];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if(newLocation)
    {
        self.currentLocation =  newLocation;
        if (self.currentLocation != nil)
        {
            NSLog(@"didUpdateLocations");
            [self getCurrentLocation:manager];
        }
    }
    
    CLLocationDistance distance = [oldLocation distanceFromLocation:newLocation];
    NSLog(@"distance %f",distance);
    
    if (distance > 100.0 ) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] length]) {
            if (self.stopLocationUpdate) {
                NSLog(@"Location Update is Stopped");
            }
            else
            {
                [self callDriverLocationWS];
            }
        }
        
    }
    else
    {
        NSLog(@"Same Location");
    }
    self.currentLocation = newLocation;
}

-(void)getCurrentLocation:(CLLocationManager*)locationManager
{
    CLLocation *location = [locationManager location];  
    CLLocationCoordinate2D coord;
    
    coord.longitude = location.coordinate.longitude;
    coord.latitude = location.coordinate.latitude;
    
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    [defaluts setObject:[NSString stringWithFormat:@"%f",coord.latitude] forKey:LATITUDE];
    [defaluts setObject:[NSString stringWithFormat:@"%f",coord.longitude] forKey:LONGITUDE];
    [defaluts synchronize];
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
//    if(locations.count)
//    {
//        self.currentLocation =  [locations lastObject];
//        if (self.currentLocation != nil)
//        {
//            NSLog(@"didUpdateLocations");
//            [self getCurrentLocation:manager];
//        }
//    }
//}
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined)
    {
    }
    else if(status == kCLAuthorizationStatusRestricted)
    {
    }
    else if(status == kCLAuthorizationStatusDenied)
    {
    }
    else if(status == kCLAuthorizationStatusAuthorized)
    {
    }
    else if(status == kCLAuthorizationStatusAuthorized) {
    }
    else //kCLAuthorizationStatusAuthorizedAlways
    {
    }
}

#pragma mark - webservice methods

-(void)callDriverNotificationCheckWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID]  forKey:@"driver_id"];
    self.objWSHelper.serviceName = @"DRIVERNOTIFICATIONSTATUS";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getDriverStatusURL:params]];
}

-(void)callDriverLocationWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID]  forKey:@"driver_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults]valueForKey:LATITUDE]  forKey:@"latitude"];
    [params setObject:[[NSUserDefaults standardUserDefaults]valueForKey:LONGITUDE]  forKey:@"longitude"];
    
    self.objWSHelper.serviceName = @"DRIVERLOCATION";
    //driver_id=&latitude=&longitude=
    [self.objWSHelper sendRequestWithURL:[WS_Urls getDriverLocationURL:params]];
}


-(void)callDriverStatusWS
{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] length]!=0){
        [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID]  forKey:@"driver_id"];
        self.objWSHelper.serviceName = @"DRIVERSTATUS";
        [self.objWSHelper sendRequestWithURL:[WS_Urls getDriverStatusURL:params]];
    }
}

#pragma mark - ParseWSDelegate Methods

-(void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id)response
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
    if (!response)
    {
        return;
    }
    NSLog(@"%@",response);
    NSMutableDictionary *dictResults=(NSMutableDictionary *)response;
    if([helper.serviceName isEqualToString:@"DRIVERSTATUS"])
    {
        [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            NSInteger orderResponseTime = [[[[self.dictUserInfo objectForKey:@"aps"] objectForKey:@"otherparam"] objectForKey:@"time"] integerValue]-1;
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"order_status"] forKey:ORDER_STATUS];
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"order_id"] forKey:ORDER_ID];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSArray *arrayViewControllers = [NSArray arrayWithArray:self.objNavController.viewControllers];
            
            BOOL isOrderView = NO;
            
            if (arrayViewControllers.count) {
                for (UIViewController *obj in arrayViewControllers) {
                    if ([obj isKindOfClass:[OrderViewController class]]) {
                        NSLog(@"is Order view");
                        isOrderView = YES;
                        return;
                    }
                }
                if (!isOrderView) {
                    LoginViewController *objLoginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                    HomeViewController *objHomeVC = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
                    OrderViewController *objOrderVC = [[OrderViewController alloc] initWithNibName:@"OrderViewController" bundle:nil];
                    [objOrderVC setTimerValue:[NSString stringWithFormat:@"%li", (long)orderResponseTime]];
                    
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:AUTO_LOGIN])
                    {
                        if(orderResponseTime > 0)
                            [self.objNavController setViewControllers:@[objLoginVC, objHomeVC, objOrderVC] animated:YES];
                        else
                            [self.objNavController setViewControllers:@[objLoginVC, objHomeVC] animated:YES];
                    }
                    else
                    {
                        [self.objNavController pushViewController:objLoginVC animated:YES];
                    }   
                }

            }
            else
            {
                LoginViewController *objLoginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                HomeViewController *objHomeVC = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
                OrderViewController *objOrderVC = [[OrderViewController alloc] initWithNibName:@"OrderViewController" bundle:nil];
                [objOrderVC setTimerValue:[NSString stringWithFormat:@"%li", (long)orderResponseTime]];
                
                if ([[NSUserDefaults standardUserDefaults] boolForKey:AUTO_LOGIN])
                {
                    if(orderResponseTime > 0)
                        [self.objNavController setViewControllers:@[objLoginVC, objHomeVC, objOrderVC] animated:YES];
                    else
                        [self.objNavController setViewControllers:@[objLoginVC, objHomeVC] animated:YES];
                }
                else
                {
                    [self.objNavController pushViewController:objLoginVC animated:YES];
                }   
            }
           
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:ORDER_STATUS];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ORDER_ID];
            
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:DRIVER_ONLINE_STATUS] forKey:DRIVER_ONLINE_STATUS];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [UIAlertView showWithTitle:APPNAME message:@"Your order is declined." handler:^(UIAlertView *alertView, NSInteger buttonIndex)
             {
                 LoadingViewController *objLoadingVC = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
                 [objLoadingVC setIsNotificationFired:NO];
                 [self.objNavController setViewControllers:@[objLoadingVC] animated:YES];
             }];
        }
    }
    else if ([helper.serviceName isEqualToString:@"DRIVERNOTIFICATIONSTATUS"]){
        if([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] isEqualToString:@"1"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"order_status"] forKey:ORDER_STATUS];
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:@"order_id"] forKey:ORDER_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            LoginViewController *objLoginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            HomeViewController *objHomeVC = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
            OrderViewController *objOrderVC = [[OrderViewController alloc] initWithNibName:@"OrderViewController" bundle:nil];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:AUTO_LOGIN])
            {
                if([[dictResults objectForKey:@"data"] count] > 0)
                    [self.objNavController setViewControllers:@[ objLoginVC,objHomeVC, objOrderVC] animated:YES];
                else
                    [self.objNavController setViewControllers:@[objHomeVC] animated:YES];
            }
            else
            {
                [self.objNavController pushViewController:objLoginVC animated:YES];
            }
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:[[[dictResults objectForKey:@"data"] objectAtIndex:0] objectForKey:DRIVER_ONLINE_STATUS] forKey:DRIVER_ONLINE_STATUS];
            if (![[NSUserDefaults standardUserDefaults] boolForKey:AUTO_LOGIN])
            {
                LoginViewController *objLoginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                [self.objNavController setViewControllers:@[objLoginVC] animated:YES];
            }
            else
            {
                NSArray *arrayViewControllers = [NSArray arrayWithArray:self.objNavController.viewControllers];
                
                for (UIViewController *obj in arrayViewControllers) {
                    if ([obj isKindOfClass:[HomeViewController class]]) {
                        [self.objNavController popToViewController:obj animated:YES];
                        return;
                    }
                }
            }
        }
        [self callDriverLocationWS];
    }
    else
    {
        
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
}

@end

