//
//  CustomMap.h
//  SampleMap
//
//  Created by CompanyName on 04/09/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomMap : NSObject <MKAnnotation>

@property (nonatomic, assign) NSInteger tag;

-(id)initWithTitle:(NSString *)newTitle andCoordinate:(CLLocationCoordinate2D)coord;


@end
