//
//  HomeViewController.h
//  BevyDriver
//
//  Created by CompanyName on 1/3/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

/**
 * This class is used to Show the map view with user current location .
 */           
@interface HomeViewController : UIViewController<UITextFieldDelegate,MKMapViewDelegate,CLLocationManagerDelegate,
MKAnnotation,ParseWSDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *MapView;
@property (strong, nonatomic) NSMutableArray *arrayMap;
@property (strong, nonatomic) MKPolyline *objPolyline;
@property (strong, nonatomic) MKPointAnnotation *origin,*destination;
@property (nonatomic, retain) NSDictionary *addressDictionary;

@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, strong) WS_Helper *objWSHelper;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property(nonatomic, retain) NSDictionary *dictStoreDetails;
@property (nonatomic, assign) CLLocationCoordinate2D driverCoord;
@property (nonatomic, strong) UISwitch *btnDriverAvailability;
@property (nonatomic, assign) BOOL isON;


@end
