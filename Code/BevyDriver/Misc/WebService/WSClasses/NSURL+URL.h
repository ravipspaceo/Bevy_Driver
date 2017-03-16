//
//  NSURL+URL.h
//  NSURLTest
//
//  Created by CompanyName on 2/18/13.
//  Copyright (c) 2013 CompanyName. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (URL)
+ (NSURL*)urlWithEncoding:(NSString*)urlString;
+ (NSURL*)fileURLWithEncoding:(NSString*)pathString;
+ (NSURL*)fileURLWithEncoding:(NSString*)pathString andDirectory:(BOOL)isDirectory;
+ (NSURL *)initFileURLWithPathEncoding:(NSString*)pathString andDirectory:(BOOL)isDirectory;
+ (NSURL *)initFileURLWithPathEncoding:(NSString*)pathString;
@end
