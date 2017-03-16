//
//  WS_Urls.m
//  PhotoBud
//
//  Created by CompanyName on 1/5/13.
//  Copyright (c) 2013 CompanyName. All rights reserved.
//

#import "WS_Urls.h"

@implementation WS_Urls

//************ APPLE STORE URLs ************//
//#define MAIN_URL @"https://www.shopbevy.com/WS/"
//#define MAIN_URL @"https://shopbevy.com/mobile_itune/WS/"
//************ - ************//


//************ STAGING URLs ************//
//#define MAIN_URL    @"http://staging.shopbevy.com/WS/"
//#define MAIN_URL    @"http://52.19.110.72/WS/"
//************ - ************//

//************ 108 Server and Local URLs ************//
//#define MAIN_URL  @"http://192.168.43.1/bevy_live_25_Feb_2015/WS/"
#define MAIN_URL  @"http://108.170.62.152/webservice/bevy/WS/"
//************ - ************//


#pragma mark - SubURLS

#define APPLICATION_SETTINGS_WS @"application_settings?"
#define LOGIN_WS @"driver_login?"
#define DRIVER_STATUS @"driver_status?"
#define FORGOT_PASSWORD @"forgot_password?"
#define OFFER_ORDER_LIST_WS @"offered_order_list?"
#define RESPONSE_THEORDER @"responce_the_order?"
#define ACCEPTED_ORDERS @"accepted_orders?"

#define PICKUP_THEORDER @"pickup_the_order?"
#define CANCEL_THEOERDER @"cancel_the_order?"
#define MAP_FOR_DRIVER @"map_for_driver?"
#define ADD_ROUTE_DETAILS @"add_route_details?"
#define NEAR_BY_STORES @"near_by_stores?"
#define GET_STORE_NEAR_BY_DRIVER @"get_store_near_by_driver?"
#define CONFIRM_THE_OREDER @"confirm_the_order?"

#define VIEW_PROFILE @"view_profile?"
#define EDIT_PROFILE @"edit_profile?"
#define CHANGE_PASSWORD @"change_password?"
#define DRIVER_AVAILABILITY @"driver_availability?"

#define DRIVER_ORDER_PROBLEM @"send_order_problem?"

#define DRIVER_LOCATION_UPDATE @"driver_location_update?"

#pragma mark - GLOBAL methods

+(NSString *)getMainUrl
{
    return MAIN_URL;
}

#pragma mark - AUTHENTICATION
+(NSString *)getApplicationSettingsURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",APPLICATION_SETTINGS_WS] andParameters:parameters];
}
+(NSString *)getLoginURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",LOGIN_WS] andParameters:parameters];
}
+(NSString *)getDriverStatusURL:(NSDictionary *)parameters;
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",DRIVER_STATUS] andParameters:parameters];
}
+(NSString *)getDriverAvailabilityURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",DRIVER_AVAILABILITY] andParameters:parameters];
}

+(NSString *)getForgotPasswordURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",FORGOT_PASSWORD] andParameters:parameters];
}
+(NSString *)getOfferedOrderListURL:(NSDictionary *)parameters
{
     return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",OFFER_ORDER_LIST_WS] andParameters:parameters];
}
+(NSString *)getResponseTheOrderURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",RESPONSE_THEORDER] andParameters:parameters];
}
+(NSString *)getAcceptedOrdersURL:(NSDictionary *)parameters
{
     return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",ACCEPTED_ORDERS] andParameters:parameters];
}
+(NSString *)getPickUpTheOredersURL:(NSDictionary *)parameters
{
     return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",PICKUP_THEORDER] andParameters:parameters];
}
+(NSString *)getCancelTheOrdersURL:(NSDictionary *)parameters
{
     return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",CANCEL_THEOERDER] andParameters:parameters];
}
+(NSString *)getMapforDriverURL:(NSDictionary *)parameters
{
     return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",MAP_FOR_DRIVER] andParameters:parameters];
}
+(NSString *)getAddRoutDetailsURL:(NSDictionary *)parameters
{
     return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",ADD_ROUTE_DETAILS] andParameters:parameters];
}
+(NSString *)getNearByStoresURL:(NSDictionary *)parameters
{
     return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",NEAR_BY_STORES] andParameters:parameters];
}
+(NSString *)getStoreNearByDriverURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",GET_STORE_NEAR_BY_DRIVER] andParameters:parameters];
}
+(NSString *)getSendOrderProblem:(NSDictionary *)parameters
{
return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",DRIVER_ORDER_PROBLEM] andParameters:parameters];
}

+(NSString *)getConfirmTheOrderURL:(NSDictionary *)parameters
{
     return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",CONFIRM_THE_OREDER] andParameters:parameters];
}
#pragma mark - PROFILE

+(NSString *)getViewProfileURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",VIEW_PROFILE] andParameters:parameters];
}

+(NSString *)getEditProfileURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",EDIT_PROFILE] andParameters:parameters];
}

+(NSString *)getChangePasswordURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",CHANGE_PASSWORD] andParameters:parameters];
}

+(NSString *)getDriverLocationURL:(NSDictionary *)parameters
{
    return [WS_Urls makeGetURL:[MAIN_URL stringByAppendingFormat:@"%@",DRIVER_LOCATION_UPDATE] andParameters:parameters];
}


#pragma mark - Url helper method
+(NSString *) makeGetURL: (NSString *) url andParameters:(NSDictionary *) paramdata
{
    if (paramdata==nil) {
        return url;
    }
    NSMutableDictionary *data=[NSMutableDictionary dictionaryWithDictionary:paramdata];    
    if ( [url rangeOfString:@"?"].length == 0)
    {
        url = [url stringByAppendingString:@"?"];
    }

    NSString *argStr=@"";
    NSArray *keyArray = [data allKeys];
    if ([keyArray count] > 0)
    {
        for ( int i = 0 ; i < [keyArray count]; i++ )
        {
            id tmp_data = [data objectForKey:[keyArray objectAtIndex:i]];
            NSString  *processed_string;
            if ([tmp_data isKindOfClass:[NSMutableArray class]])
            {
                NSMutableArray *tmp_arr;// = [[NSMutableArray alloc] init];
                tmp_arr = (NSMutableArray *) tmp_data;
                processed_string = [tmp_arr componentsJoinedByString:@","];
            }
            else
            {
                processed_string = (NSString *) tmp_data;
            }
            argStr = [argStr stringByAppendingFormat:@"&%@=%@" , [keyArray objectAtIndex:i] , processed_string];
        }
    }
    argStr = ([argStr length] > 0) ? [argStr stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""] : argStr;
    url=[url stringByAppendingFormat:@"%@",argStr];
    url=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return url;
}

@end
