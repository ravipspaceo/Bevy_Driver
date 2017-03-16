//
//  RouteDirectionViewController.h
//  Bevy
//
//  Created by CompanyName on 1/2/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

/**
 * This class is used to Show the map Route direction pickup location, delivery location.
 */

@interface RouteDirectionViewController : UIViewController<UITextFieldDelegate,MKMapViewDelegate,CLLocationManagerDelegate,MKOverlay,
MKAnnotation,ParseWSDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *MapView;
@property(nonatomic, retain) IBOutlet UIView *popupView;
@property(nonatomic, retain) IBOutlet UILabel *lblAnnotationTitle;
@property(nonatomic, retain) IBOutlet UILabel *lblAnnotationDescription;

@property(nonatomic, assign) BOOL isPickup;
@property(nonatomic, assign) NSInteger currentCallout;
@property(nonatomic, retain) NSDictionary *addressDictionary;
@property (strong, nonatomic) NSArray *arrayMap;

@property (strong, nonatomic) MKPolyline *objPolyline;
@property (strong, nonatomic) MKPointAnnotation *origin,*destination;

@property (nonatomic,strong) MBProgressHUD *HUD;
@property(nonatomic, retain) WS_Helper *objWSHelper;
@property(nonatomic, retain) NSString *strOrderId;
@property (nonatomic, retain) NSDictionary *dictDetails;
@property (nonatomic, retain) NSTimer *timer;

@property(nonatomic, retain) CLLocation *driverLocation;
@property (nonatomic, assign) BOOL isFirstTime;

@end
