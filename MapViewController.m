//
//  MapViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mapView.delegate = self;
    self.mapView.showsUserLocation = true;

    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;

    [self loadBike];
}

-(void)loadBike
{

    MKPointAnnotation *bikeAnnotation = [[MKPointAnnotation alloc]init];
    bikeAnnotation.coordinate = self.bike.coordinate;
    [self.mapView addAnnotation:bikeAnnotation];
    self.bikeAnnotation = bikeAnnotation;

    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    CLLocationCoordinate2D center = bikeAnnotation.coordinate;
    [self.mapView setRegion:MKCoordinateRegionMake(center, span)];
    bikeAnnotation.title = self.bike.bikeName;
}



//This shows our annotation image
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pinAnnotation = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
    //THIS SETS THE IMAGE TO JUST THE MOBILE MAKERS LOCATION AND THE  ADD ANNOTATION AND USERLOCATION TO DEFAULT
    if ([annotation isEqual:self.bikeAnnotation]) {
        pinAnnotation.image = [UIImage imageNamed:@"bikeImage"];
    } else if ([annotation isEqual:mapView.userLocation])
    {
        return nil;
    }
    pinAnnotation.canShowCallout = YES;
    pinAnnotation.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return pinAnnotation;


}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:self.bikeAnnotation.coordinate addressDictionary:nil]];

//    mapItem.placemark.coordinate = self.bikeAnnotation.coordinate;

    [self pullDirectionsWithMapItem:mapItem];
}


-(void)pullDirectionsWithMapItem:(MKMapItem *)mapItem
{
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = mapItem;
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
     {
         NSArray *routes = response.routes;
         MKRoute *theRoute = [routes objectAtIndex:0];
         NSMutableString *stepString = [NSMutableString new];
         int stepCount = 1;

         for (MKRouteStep *step in theRoute.steps) {
             [stepString appendFormat:@"%i %@\n", stepCount, step.instructions];
             stepCount++;
         }
         UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Directions" message:[NSString stringWithFormat:@"%@", stepString] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Thanks", nil];
         [alertView show];
         NSLog(@"%@", stepString);
     }];
}
@end
