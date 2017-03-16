//
//  GlobalUtilityClass.h
//  ChatAppBase
//
//  Created by CompanyName on 1/18/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalUtilityClass : NSObject
+(NSString *) getImagePathForUserProfile:(NSString *)strUserJID;
+(NSString *) getThumbImagePathForUserProfile:(NSString *)strUserJID;
+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize andImage:(UIImage *)sourceImage;
+ (NSData *)getCompressDataFromImage:(UIImage *)image;
+(NSString *)getImagePathForMedia;
+(NSString *)getStringFromDate:(NSDate *)date;
@end
