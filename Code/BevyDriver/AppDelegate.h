//
//  AppDelegate.h
//  BevyDriver
//
//  Created by CompanyName on 1/2/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WS_Helper.h"

@protocol CustomLocationManagerDelegate <NSObject>

-(void)didUpdateCurrentLocation:(CLLocation *)location;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate, ParseWSDelegate>

@property (nonatomic, retain) id<CustomLocationManagerDelegate> locationDelegate;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *objNavController;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (strong , nonatomic) NSString *strTransaction,*strPickUpInProcess;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSDictionary *dictUserInfo;
@property (nonatomic, retain) WS_Helper *objWSHelper;

@property (nonatomic, assign) BOOL stopLocationUpdate;

@property (nonatomic, assign) BOOL appInBackGround;

/**
 *  This method is used to create instance of MKMapView.
 */
-(MKMapView *)getMapViewInstance;

/**
 *  This method is used to create CustomLocationManagerDelegate.
 */
-(void)setCustomLocationDelegate:(id<CustomLocationManagerDelegate>)locationDelegate;

@end

