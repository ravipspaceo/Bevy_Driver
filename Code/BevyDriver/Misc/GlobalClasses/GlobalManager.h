//
//  Jupper
//
//  Created by CompanyName.
//  Copyright (c) 2012 CompanyName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AFJSONRequestOperation.h"
#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>

typedef enum
{
    OnGoingEvents,
    RecomendedEvents,
    PopularEvents
} EventsType;

typedef enum
{
    FavoriteView,
    PointsEarnedView
} ViewType;

@interface GlobalManager : NSObject
+ (void)setOperationInstance:(AFJSONRequestOperation *)instance;
@property (nonatomic, assign) BOOL isLoggedOut;
@property (nonatomic, assign) BOOL hasAppLaunched;
@property (nonatomic, strong) NSString *strDeviceToken;
@property (nonatomic, assign) BOOL profileNeedsToRefresh;
@property (strong, nonatomic) CLLocation *mySessionLocation;
@property (assign, nonatomic) EventsType myEventType;
@property (nonatomic, strong) NSMutableArray *arCategories;
@property (nonatomic, assign) BOOL eventsNeedsToRefresh;


+(UIBarButtonItem *)getnavigationRightButtonWithTarget:(id)target :(NSString *)strImageName;
+(UIBarButtonItem *)getnavigationLeftButtonWithTarget:(id)target :(NSString *)strImageName;
+(NSArray *)getnavigationRightButtonsWithTarget:(id)target :(NSString *)strImageName withTarget2:(id)target2 :(NSString *)strImageName2;


+ (GlobalManager*) sharedInstance;
+(void)addAnimationToView : (UIView *)view;
+ (BOOL) checkInternetConnection;
+ (AppDelegate*) getAppDelegateInstance;
+(void)showDidFailError:(NSError *)error;

+(NSMutableArray *)getDummyData;
+(NSString*)getValurForKey :(NSMutableDictionary*)dict : (NSString*)key;
+ (UIScrollView*) scrollViewToCenterOfScreenInProfile:(UIScrollView*)_scrlView theView:(UIView *)theView toShow:(BOOL)toShow;
+ (UIImage*)getImageFromResource:(NSString*)imageName;

+(NSString *) checkForNull:(id) obj;

+(NSDate *)getDateFromString:(NSString *)strDate;

+(void)customPlaceHoder:(UITextField*)textField placeHoderStr:(NSString*)placeHoderSr;
#pragma mark - load more
+ (NSInteger)loadMore : (NSInteger)numberOfItemsToDisplay arrayTemp:(NSMutableArray*)aryItems tblView:(UITableView*)tblList;

#pragma mark Custom setup methods
//Custom setup methods

+(NSString *) formatPhoneNumberToUS:(NSString *) normalPhoneNo;
+ (void) showStartProgress : (UIViewController*) parentView;

#pragma mark IMAGE Ops
+ (UIImage *)makeResizedImage:(CGSize)newSize quality:(CGInterpolationQuality)interpolationQuality withImage:(UIImage*)oldImage isAspectFit:(BOOL)isAspectFit;
+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize andImage:(UIImage *) sourceImage;
+(UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)destSize;

#pragma mark - Table Font & Color
+ (UIFont *)FontLightForSize:(int)size;
+ (UIFont *)FontForSize:(int)size;
+ (UIFont *)FontMediumForSize:(int)size;
+ (UIFont *)FontBoldForSize:(int)size;

+(UIFont *)fontMuseoSans100:(int)size;
+(UIFont *)fontMuseoSans300:(int)size;
+(UIFont *)fontMuseoSans500:(int)size;
+(UIFont *)fontOswaldStncil:(int)size;

+(NSInteger)getAgeFromDate:(NSDate*)birthDate;
+(NSDate *)getDateFromBefore18Years;

+ (UIColor*)BlackButtonTintColor;
+ (UIColor*)BlackButtonHeighlightedTintColor;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColorAndArrow:(UIColor *)color;
+ (NSDateFormatter *)DateFormatee;
//+(UIBarButtonItem *)getnavigationLeftDriverButtonWithTarget:(id)target :(NSString *)strImageName;
+(UIBarButtonItem *)getnavigationRightDriverButtonWithTarget:(id)target withAction:(SEL)selector;
+(UIBarButtonItem *)getnavigationLeftProfileButtonWithTarget:(id)target :(NSString *)strImageName;
#pragma mark - Toolbar for navigationbar
+ (UIToolbar*) setTopBar;

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
+ (UIFont *) getMediumFontForSize:(int)fontSize;
@end

//Category for UINavigation bar
@interface UIViewController (CustomeAction)
-(void)setBackButton;
-(void)setOrderRightBarButton;
-(void)setLeftButton;
-(void)setProfileRightBarButton;
-(void)setLeftBarButtonWithTitle:(NSString *)buttonTitle;
-(void)setRightBarButton;
-(void)removeBackButton;
-(void)btnBackButtonClicked:(id)sender;


@end