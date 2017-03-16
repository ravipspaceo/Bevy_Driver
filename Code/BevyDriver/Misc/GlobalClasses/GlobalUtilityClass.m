//
//  GlobalUtilityClass.m
//  ChatAppBase
//
//  Created by CompanyName on 1/18/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import "GlobalUtilityClass.h"

@implementation GlobalUtilityClass

+(NSString *) getImagePathForUserProfile:(NSString *)strUserJID{
    NSString *userProfilePath = @"";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *mediaPath = [libraryDirectory stringByAppendingPathComponent:@"Media"];
    NSString *profileDirectory = [mediaPath stringByAppendingPathComponent:@"Profile"];
    BOOL isDir = NO;
    if(![[NSFileManager defaultManager] fileExistsAtPath:profileDirectory isDirectory:&isDir]){
        [[NSFileManager defaultManager] createDirectoryAtPath:profileDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    userProfilePath = [profileDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", strUserJID]];
    return userProfilePath;
}


+(NSString *) getThumbImagePathForUserProfile:(NSString *)strUserJID{
    NSString *userProfilePath = @"";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *mediaPath = [libraryDirectory stringByAppendingPathComponent:@"Media"];
    NSString *profileDirectory = [mediaPath stringByAppendingPathExtension:@"Profile"];
    BOOL isDir = NO;
    if(![[NSFileManager defaultManager] fileExistsAtPath:profileDirectory isDirectory:&isDir]){
        [[NSFileManager defaultManager] createDirectoryAtPath:profileDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    userProfilePath = [profileDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_thumb.png", strUserJID]];
    return userProfilePath;
}

+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize andImage:(UIImage *)sourceImage
{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}

+(NSData *)getCompressDataFromImage:(UIImage *)image{
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.05f;
    int maxFileSize = 120 * 120;
    NSData *imageDataTemp = UIImageJPEGRepresentation(image, compression);
    while ([imageDataTemp length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageDataTemp = UIImageJPEGRepresentation(image, compression);
    }
    return imageDataTemp;
}


+(NSString *)getImagePathForMedia{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *mediaPath = [libraryDirectory stringByAppendingPathComponent:@"Media"];
    
    mediaPath = [mediaPath stringByAppendingPathComponent:@"/Photo"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:mediaPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:mediaPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return mediaPath;
}




+(NSString *)getStringFromDate:(NSDate *)date{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    
    
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"dd-MM-yyyy hh:mm a"];
    NSString *strDate = [formatter stringFromDate:date];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    NSString *date1 = [formatter stringFromDate:date];
    NSString *date2 = [formatter stringFromDate:[NSDate date]];
    if ([date1 isEqualToString:date2]){
        [formatter setDateFormat:@"hh:mm a"];
        
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:date];
        if (timeInterval<0)
            timeInterval = 0;
        strDate = [formatter stringFromDate:date];
        
        strDate = [NSString stringWithFormat:@"%@",strDate];
        
    }
    else
    {
        [formatter setDateFormat:@"dd-MM-yyyy 00:00"];
        NSDate *tempdate = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
        if ([tempdate timeIntervalSinceDate:date]<3600*24*7){
            [formatter setDateFormat:@"EEE, hh:mm a"];
            strDate = [formatter stringFromDate:date];
            
            strDate = [NSString stringWithFormat:@"%@",strDate];
        }
        else
        {
            
            [formatter setDateFormat:@"dd-MM hh:mm a"];
            strDate = [formatter stringFromDate:date];
            
        }
    }
    
    
    return strDate;
}



@end
