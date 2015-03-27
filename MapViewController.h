//
//  MapViewController.h
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Bike.h"

@interface MapViewController : UIViewController
@property NSMutableArray *arrayOfBikes;
@property Bike *bike;
@property CLLocationCoordinate2D coordinate;
@property MKPointAnnotation *bikeAnnotation;

@end
