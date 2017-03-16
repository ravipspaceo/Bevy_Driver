//
//  RouteDirectionViewController.m
//  Bevy
//
//  Created by CompanyName on 1/2/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//

#import "RouteDirectionViewController.h"
#import "CustomMap.h"
#import "ProfileViewController.h"

#define SECONDS 30.0

@interface RouteDirectionViewController ()

@end

@implementation RouteDirectionViewController

@synthesize coordinate,boundingMapRect;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - ViewLifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.objWSHelper = [[WS_Helper alloc] initWithDelegate:self];
    self.isFirstTime = YES;
    [self setUpLayout];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.driverLocation = [[CLLocation alloc] initWithLatitude:[GlobalManager getAppDelegateInstance].currentLocation.coordinate.latitude longitude:[GlobalManager getAppDelegateInstance].currentLocation.coordinate.longitude];
    [self callAddRouteWS];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
   {
       //Background;
       dispatch_async(dispatch_get_main_queue(), ^
      {
          //main thread;
          self.timer = [NSTimer scheduledTimerWithTimeInterval:SECONDS target:self selector:@selector(callAddRouteWS) userInfo:nil repeats:YES];
          [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
      });
   });
    return;
}

-(void)viewWillDisappear:(BOOL)animated
{
    if(self.timer != nil)
    {
        [self.timer invalidate];
    }
}

#pragma mark - Instance Methods

-(void)setUpLayout
{
    self.navigationItem.title =@"Route Direction";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans" size:18],NSFontAttributeName, nil]];
    self.navigationItem.rightBarButtonItem = [GlobalManager getnavigationRightButtonWithTarget:self :@"userProfile"];
    [self setBackButton];
    [self.MapView setDelegate:self];
    [self.MapView setShowsUserLocation:YES];

    if(self.isPickup)
    {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[NSString stringWithFormat:[self.dictDetails valueForKey:@"pickup_lat"], coord.latitude] floatValue], [[NSString stringWithFormat:[self.dictDetails valueForKey:@"pickup_long"], coord.longitude] floatValue]);
        CustomMap *customMap=[[CustomMap alloc]initWithTitle:[self.dictDetails valueForKey:@"pickup_address"] andCoordinate:coord];
        [customMap setTag:2];
        [self.MapView addAnnotations:@[customMap]];                                 
    }
    else//Delivery
    {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[NSString stringWithFormat:[self.dictDetails valueForKey:@"delivery_latitude"], coord.latitude] floatValue], [[NSString stringWithFormat:[self.dictDetails valueForKey:@"delivery_longitude"], coord.longitude] floatValue]);
        CustomMap *customMap=[[CustomMap alloc]initWithTitle:[self.dictDetails valueForKey:@"delivery_address"] andCoordinate:coord];
        [customMap setTag:2];
        [self.MapView addAnnotations:@[customMap]];
    }
}

-(void)btnProfileClicked
{
    ProfileViewController *objProfil =[[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
    [self.navigationController pushViewController:objProfil animated:YES];
}

#pragma mark - MKMapViewDelegate methods
-(void)mapView:(MKMapView*)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.driverLocation = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
}

-(void)mapView:(MKMapView*)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
    NSString *currentAddress = @"Current Location";
    if(self.addressDictionary != nil)
    {
        currentAddress = [[self.addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@","];
    }
        
    if([view.annotation isKindOfClass:[CustomMap class]])
    {
        CustomMap *annotation = (CustomMap *)view.annotation;
        if(self.isPickup)
        {
            [self.lblAnnotationTitle setText:@"Pickup Location"];
            [self.lblAnnotationDescription setText:annotation.title];
        }
        else//Delivery
        {
            [self.lblAnnotationTitle setText:@"Delivery Location"];
            [self.lblAnnotationDescription setText:annotation.title];
        }
    }
    else
    {
        [self.lblAnnotationTitle setText:@"Driver Location"];
        [self.lblAnnotationDescription setText:currentAddress];
    }
    
    [view addSubview:self.popupView];
    [self.popupView setCenter:CGPointMake(-(self.popupView.bounds.size.width*0.5f - 20), -self.popupView.bounds.size.height*0.5f)];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *identifier=@"com.identifier.bevydriver";
    MKAnnotationView *pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    if([annotation isKindOfClass:[MKUserLocation class]])
    {
        [pinView setImage:[UIImage imageNamed:@"deliverytruckpin"]];
    }
    else
    {
        if(self.isPickup)
        {
            [pinView setImage:[UIImage imageNamed:@"Shop-Food_pin"]];
        }
        else//Delivery
        {
            [pinView setImage:[UIImage imageNamed:@"GPS-Location-Symbol_pin"]];
        }
    }
    return pinView;
}

-(void)onSingleTap:(UITapGestureRecognizer *)gesture
{
    NSArray *selectedAnnotations = self.MapView.selectedAnnotations;
    for (CustomMap *annotationView in selectedAnnotations)
    {
        [self.MapView deselectAnnotation:annotationView animated:YES];
        [self.popupView removeFromSuperview];
    }
    [self.view removeGestureRecognizer:gesture];
}

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
         NSLog(@"2nd FormattedAddressLine: %@", [[self.addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@","]);
     }];
}

#pragma mark - MkMapRoute methods

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
            if (MKMapRectIsNull(zoomRect))
            {
                zoomRect = pointRect;
            }
            else
            {
                zoomRect = MKMapRectUnion(zoomRect, pointRect);
            }
        }
        [self.MapView setVisibleMapRect:zoomRect animated:YES];
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
        [self.MapView setVisibleMapRect:zoomRect animated:YES];
    }
    
    [self performSelector:@selector(drawPath) withObject:nil afterDelay:0.1];
}

-(void)centerMap
{
    if ([self.MapView.annotations count] == 0)
        return;
    int i = 0;
    MKMapPoint points[[self.MapView.annotations count]];
    //build array of annotation points
    for (id<MKAnnotation> annotation in [self.MapView annotations])
        points[i++] = MKMapPointForCoordinate(annotation.coordinate);
    
    MKPolygon *poly = [MKPolygon polygonWithPoints:points count:i];
    [self.MapView setRegion:MKCoordinateRegionForMapRect([poly boundingMapRect]) animated:YES];
}

-(void)drawPath
{
    NSArray *array = [self.MapView annotations];
    for(CustomMap *annotation in array)
    {
        if ([annotation isKindOfClass:[MKUserLocation class]])
        {
            self.origin = (MKPointAnnotation *)annotation;
        }
        else
        {
            self.destination = (MKPointAnnotation *)annotation;
        }
    }
    
    self.arrayMap=[self getRoutePointFrom:self.origin to:self.destination];
    [self drawRoute];
}

-(void)drawRoute
{
    long numPoints=[self.arrayMap count];
    if(numPoints>1)
    {
        CLLocationCoordinate2D* coords = malloc(numPoints * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < numPoints; i++)
        {
            CLLocation* current = [self.arrayMap objectAtIndex:i];
            coords[i] = current.coordinate;
        }
        
        self.objPolyline = [MKPolyline polylineWithCoordinates:coords count:numPoints];
        free(coords);
        [self.MapView removeOverlays:self.MapView.overlays];
        [self.MapView addOverlay:self.objPolyline];
        [self.MapView setNeedsDisplay];
    }
}

- (MKOverlayView*)mapView:(MKMapView*)theMapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *view = [[MKPolylineView alloc] initWithPolyline:self.objPolyline];
    view.fillColor = (self.isPickup) ? [UIColor greenColor] : [UIColor redColor];
    view.strokeColor = (self.isPickup) ? [UIColor greenColor] : [UIColor redColor];
    view.lineWidth = 7;
    return view;
}

- (NSArray*)getRoutePointFrom:(MKPointAnnotation *)origin to:(MKPointAnnotation *)destination
{
    MKDirectionsRequest *routeRequest=[[MKDirectionsRequest alloc]init];
    routeRequest.transportType=MKDirectionsTransportTypeWalking;
    NSString *saddr=[NSString stringWithFormat:@"%f,%f",origin.coordinate.latitude,origin.coordinate.longitude];
    NSString *daddr=[NSString stringWithFormat:@"%f,%f",destination.coordinate.latitude,destination.coordinate.longitude];
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
    NSError *error;
    NSString *apiResponse = [NSString stringWithContentsOfURL:[NSURL URLWithString:apiUrlStr] encoding:NSUTF8StringEncoding error:&error];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"points:\\\"([^\\\"]*)\\\"" options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:apiResponse options:0 range:NSMakeRange(0, [apiResponse length])];
    NSString *encodedPoints = [apiResponse substringWithRange:[match rangeAtIndex:1]];
    return [self decodePolyLine:[encodedPoints mutableCopy]];
}

- (NSMutableArray *)decodePolyLine:(NSMutableString *)encodedString
{
    [encodedString replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:NSLiteralSearch range:NSMakeRange(0, [encodedString length])];
    NSInteger len = [encodedString length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encodedString characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encodedString characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

#pragma mark - WS calling methods

-(void)callAddRouteWS
{
    if(self.isFirstTime)
        [[MBProgressHUD showHUDAddedTo:[GlobalManager getAppDelegateInstance].window animated:YES] setLabelText:@"Please wait"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:DRIVER_ID] forKey:@"driver_id"];
    [params setObject:self.strOrderId forKey:@"order_id"];
    [params setObject:[NSString stringWithFormat:@"%f", self.driverLocation.coordinate.latitude]  forKey:@"latitude"];
    [params setObject:[NSString stringWithFormat:@"%f", self.driverLocation.coordinate.longitude]  forKey:@"longitude"];
    [self.objWSHelper sendRequestWithURL:[WS_Urls getAddRoutDetailsURL:params]];
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
    if ([[[dictResults objectForKey:@"settings"] objectForKey:@"success"] integerValue] == 1)
    {
        NSLog(@"SUCCESS");
        dispatch_async(dispatch_get_main_queue(), ^
       {
           //main thread;
           [self getAddressFromLatLon:self.driverLocation];
           if(self.isFirstTime)
               [self updatePins];
           self.isFirstTime = NO;
       });
    }
    else
    {
        NSLog(@"FAILURE");
    }
}

-(void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window animated:YES];
}

@end