//
//  WS_Urls.h
//  PhotoBud
//
//  Created by CompanyName on 1/5/13.
//  Copyright (c) 2013 CompanyName. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WS_Urls : NSObject


+(NSString *) makeGetURL: (NSString *) url andParameters:(NSDictionary *) paramdata;
+(NSString *)getMainUrl;

#pragma mark - AUTHENTICATION
+(NSString *)getApplicationSettingsURL:(NSDictionary *)parameters;
+(NSString *)getLoginURL:(NSDictionary *)parameters;
+(NSString *)getDriverStatusURL:(NSDictionary *)parameters;
+(NSString *)getForgotPasswordURL:(NSDictionary *)parameters;

#pragma mark - OFFEREDORDERLIST
+(NSString *)getOfferedOrderListURL:(NSDictionary *)parameters;

#pragma mark - RESPONSETHEORDER
+(NSString *)getResponseTheOrderURL:(NSDictionary *)parameters;

#pragma mark - ACCEPTEDORDERS
+(NSString *)getAcceptedOrdersURL:(NSDictionary *)parameters;

#pragma mark - PICKUPTHEPRDER
+(NSString *)getPickUpTheOredersURL:(NSDictionary *)parameters;

#pragma mark - CANCELTHEPRDER
+(NSString *)getCancelTheOrdersURL:(NSDictionary *)parameters;

#pragma mark - MAPFORDRIVER
+(NSString *)getMapforDriverURL:(NSDictionary *)parameters;

#pragma mark -ADDROUTDETAILS
+(NSString *)getAddRoutDetailsURL:(NSDictionary *)parameters;

#pragma mark - NEARBYSTORES
+(NSString *)getNearByStoresURL:(NSDictionary *)parameters;

#pragma mark - GETSTORESNEARBYDRIVER
+(NSString *)getStoreNearByDriverURL:(NSDictionary *)parameters;

#pragma mark - CONFIRMTHEORDER
+(NSString *)getConfirmTheOrderURL:(NSDictionary *)parameters;

#pragma mark - Sendproblem
+(NSString *)getSendOrderProblem:(NSDictionary *)parameters;

#pragma mark - Driver Location Update
+(NSString *)getDriverLocationURL:(NSDictionary *)parameters;


#pragma mark - PROFILE

+(NSString *)getViewProfileURL:(NSDictionary *)parameters;
+(NSString *)getEditProfileURL:(NSDictionary *)parameters;
+(NSString *)getChangePasswordURL:(NSDictionary *)parameters;
+(NSString *)getDriverAvailabilityURL:(NSDictionary *)parameters;
@end
