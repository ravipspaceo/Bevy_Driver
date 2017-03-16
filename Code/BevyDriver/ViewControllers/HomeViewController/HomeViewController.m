//
//  HomeViewController.m
//  BevyDriver
//
//  Created by CompanyName on 1/3/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import "HomeViewController.h"
#import "CustomMap.h"
#import "ProfileViewController.h"
#import "OrderViewController.h"

//#define SECONDS 30.0
#define SECONDS [[[[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_SETTINGS] valueForKey:GET_NEAR_BY_STORES_TIME] intValue]


@interface HomeViewController ()
{
    BOOL isFirstTime;
    UIButton *rightButton;
}

@end

@implementation HomeViewController

@synthesize coordinate;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.objWSHelper = [[WS_Helper alloc] init];
    [self.objWSHelper setTarget:self];
    isFirstTime = YES;
    [self setUpUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [GlobalManager getAppDelegateInstance].stopLocationUpdate = NO;
    
    [self.navigationController setNavigationBarHidden:NO];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:DRIVER_ONLINE_STATUS] isEqualToString:@"Yes"]) {
        [self.MapView setShowsUserLocation:YES];
        [self callStoresNearByDriverWs];
    }
    [self startBackgroudThread];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.MapView setShowsUserLocation:NO];
    if(self.timer != nil)
    {
        [self.timer invalidate];
    }
}

#pragma mark - Instance Methods

-(void)setUpUI
{
    self.navigationItem.title =@"";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans-Light" size:18],NSFontAttributeName, nil]];
    self.navigationItem.leftBarButtonItem = [GlobalManager getnavigationLeftProfileButtonWithTarget:self :@"userProfile"];
    self.navigationItem.rightBarButtonItem=[GlobalManager getnavigationRightDriverButtonWithTarget:self withAction:@selector(btnDriverAvailabilityClicked:)];
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:DRIVER_ONLINE_STATUS] isEqualToString:@"No"]) {
        [rightButton setImage:[UIImage imageNamed:@"offline"] forState:UIControlStateNormal];
        [rightButton setImage:[UIImage imageNamed:@"offline"] forState:UIControlStateSelected];
        self.isON = NO;
        
        if(self.timer != nil)
            [self.timer invalidate];
        
        [rightButton setImage:[UIImage imageNamed:@"offline"] forState:UIControlStateNormal];
        [rightButton setImage:[UIImage imageNamed:@"offline"] forState:UIControlStateSelected];
        NSMutableArray * annotationsToRemove = [self.MapView.annotations mutableCopy];
        [annotationsToRemove removeObject:self.MapView.userLocation];
        [self.MapView removeAnnotations:annotationsToRemove ];
        [self.MapView setShowsUserLocation:NO];
    }
    else
    {
        [rightButton setImage:[UIImage imageNamed:@"online"] forState:UIControlStateNormal];
        [rightButton setImage:[UIImage imageNamed:@"online"] forState:UIControlStateSelected];
        self.isON = YES;
    }
}

-(void)startBackgroudThread
{
    if (self.isON)
    {
        if(self.timer != nil)
            [self.timer invalidate];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
       {
           //Background;
           dispatch_async(dispatch_get_main_queue(), ^
          {
              //main thread;
              self.timer = [NSTimer scheduledTimerWithTimeInterval:SECONDS target:self selector:@selector(callStoresNearByDriverWs) userInfo:nil repeats:YES];
              [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
          });
       });
    }
}

-(void)btnHomeProfileClicked
{
    ProfileViewController *objProfil =[[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
    [self.navigationController pushViewController:objProfil animated:YES];
}

-(void)btnDriverAvailabilityClicked:(UIButton*)sender
{
    rightButton = sender;
    [self callDriverAvailabilityONWS];
}

#pragma mark - MKMapViewDelegate Methods

-(void)mapView:(MKMapView*)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.driverCoord=userLocation.location.coordinate;
    [self centerMap];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *pinView = nil;
        if([annotation isKindOfClass:[MKUserLocation class]])
        {
            pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"com.identifier.bevydriver"];
            if(pinView == nil)
                pinView= [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"com.identifier.bevydriver"];
            [pinView setImage:[UIImage imageNamed:@"deliverytruckpin"]];
            return pinView;
        }
        else
        {
            pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"com.identifier.bevydriver"];
            if(pinView == nil)
                pinView= [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"com.identifier.bevydriver"];
            [pinView setImage:[UIImage imageNamed:@"GPS-Location-Symbol_pin"]];
            return pinView;
        }
}

#pragma mark - MapAddress Methods

-(void)getAddressFromLatLon:(CLLocation *)bestLocation
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:bestLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error)
         {
             NSLog(@"Geocode failed with error: %@", error);
             return;
         }
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         self.addressDictionary = [NSDictionary dictionaryWithDictionary:placemark.addressDictionary];
         NSLog(@"1st FormattedAddressLine: %@", [[self.addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@","]);
     }];
}

-(void)updatePins
{
    if([self.MapView isUserLocationVisible])
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(self.MapView.userLocation.coordinate);
        MKMapRect zoomRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        
        for (id <MKAnnotation> annotation in self.MapView.annotations)
        {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
            if (MKMapRectIsNull(zoomRect)) {
                zoomRect = pointRect;
            } else {
                zoomRect = MKMapRectUnion(zoomRect, pointRect);
            }
        }
    }
    else
    {
        MKMapRect zoomRect =MKMapRectNull;
        for (id <MKAnnotation> annotation in self.MapView.annotations)
        {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
            if (MKMapRectIsNull(zoomRect))
            {
                zoomRect = pointRect;
            }
            else
            {
                zoomRect = MKMapRectUnion(zoomRect, pointRect);
            }
        }
    }
}

-(void)centerMap
{
    if ([self.MapView.annotations count] == 0)
        return;
    [self.MapView setRegion:MKCoordinateRegionMake(self.driverCoord, MKCoordinateSpanMake(0.05, 0.05)) animated:YES];
}

#pragma mark - WS calling methods

-(void)callStoresNearByDriverWs
{
    if(isFirstTime)
        [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    isFirstTime =NO;
    
    if ([GlobalManager getAppDelegateInstance].appInBackGround) {
        return;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID]  forKey:@"driver_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:LATITUDE]  forKey:@"driver_lat"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:LONGITUDE]  forKey:@"driver_long"];
    
    self.objWSHelper.serviceName = @"StoresNearByDriver";
    [self.objWSHelper sendRequestWithURL:[WS_Urls getStoreNearByDriverURL:params]];
}

-(void)callDriverAvailabilityONWS
{
    [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] forKey:@"user_id"];
    [params setObject:([rightButton isSelected] ? @"Yes" : @"No") forKey:@"available"];//(self.isON ? @"Yes" : @"No")
    self.isON = ([rightButton isSelected] ? YES : NO);//Selected is offline.
    
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
    if([helper.serviceName isEqualToString:@"StoresNearByDriver"])
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            NSArray *arrayStores = [NSArray arrayWithArray:[dictResults objectForKey:@"data"]];
            NSMutableArray *arrayAnnotation=[[NSMutableArray alloc]initWithCapacity:arrayStores.count];
            
            for(NSInteger i=0;i<arrayStores.count; i++)
            {
                NSDictionary *dict = [arrayStores objectAtIndex:i];
                MKPointAnnotation *annotation=[[MKPointAnnotation alloc] init];
                [annotation setCoordinate:CLLocationCoordinate2DMake([[dict objectForKey:@"store_latitude"] floatValue], [[dict objectForKey:@"store_longitude"] floatValue])];
                [arrayAnnotation addObject:annotation];
            }
            [self.MapView addAnnotations:arrayAnnotation];
            [self performSelector:@selector(updatePins) withObject:nil afterDelay:0.1];
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[[dictResults objectForKey:@"settings"] objectForKey:@"message"] handler:nil];
            return;
        }
    }
    else if([helper.serviceName isEqualToString:@"DriverAvailability"])
    {
        if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
        {
            [rightButton setSelected:![rightButton isSelected]];
            if(self.isON)//Online
            {
                [rightButton setImage:[UIImage imageNamed:@"online"] forState:UIControlStateNormal];
                [rightButton setImage:[UIImage imageNamed:@"online"] forState:UIControlStateSelected];
                [self.MapView setShowsUserLocation:YES];
                [self callStoresNearByDriverWs];
                [self startBackgroudThread];
            }
            else
            {
                if(self.timer != nil)
                    [self.timer invalidate];
                
                [rightButton setImage:[UIImage imageNamed:@"offline"] forState:UIControlStateNormal];
                [rightButton setImage:[UIImage imageNamed:@"offline"] forState:UIControlStateSelected];
                NSMutableArray * annotationsToRemove = [self.MapView.annotations mutableCopy];
                [annotationsToRemove removeObject:self.MapView.userLocation];
                [self.MapView removeAnnotations:annotationsToRemove ];
                [self.MapView setShowsUserLocation:NO];
            }
        }
        else
        {
            [UIAlertView showWithTitle:APPNAME message:[GlobalManager getValurForKey:[dictResults objectForKey:@"settings"] :@"message"] handler:nil];
        }
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
}

@end
