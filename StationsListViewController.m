//
//  StationsListViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StationsListViewController.h"
#import "MapViewController.h"
#import "Bike.h"

@interface StationsListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray *arrayofBikes;
@property NSMutableArray *filteredArrayOfBikes;
@property CLLocationManager *locationManager;
@property CLLocation *userLocation;
@property BOOL *isFiltered;
@property BOOL *isAscending;



@end

@implementation StationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchBar.delegate = self;

    self.arrayofBikes = [NSMutableArray new];
    self.filteredArrayOfBikes = [NSMutableArray arrayWithCapacity:[self.arrayofBikes count]];
    [self getDataFromWebsite];

    self.locationManager = [CLLocationManager new];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
    self.isFiltered = NO;
    self.isAscending = YES;

    [self sortTableview];

}

#pragma mark - GET DATA FROM API

-(void)getDataFromWebsite
{

    NSString *myURLString = @"http://www.bayareabikeshare.com/stations/json";

    NSURL *url = [NSURL URLWithString:myURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        [self downloadComplete:data];
        
    }];
    
}


-(void)downloadComplete:(NSData *)data
{

    // convert data into object
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

    NSArray *arry = dict[@"stationBeanList"];

    // we have an array of dictionaries want to convert into an array of bus stop objects

    // for each dictionary make object
    for (NSDictionary *dict2 in arry){

        [self unpackDictionaryAndCreateBusStop:dict2];

    }

    // reload table view
    [self.tableView reloadData];
    
}


-(void)unpackDictionaryAndCreateBusStop:(NSDictionary *)dict2
{
    // get lat and long
    NSString *lat = dict2[@"latitude"];
    double latAsDouble = lat.doubleValue;

    NSString *longitude = dict2[@"longitude"];
    double longAsDouble = longitude.doubleValue;

    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latAsDouble, longAsDouble);

    NSString *bikeAmount = dict2[@"availableBikes"];
    int availableBikes = bikeAmount.intValue;

    // create new bus stop obj
    Bike *bike = [Bike new];
    bike.bikeName = dict2[@"stAddress1"];
    bike.numberOfBikes = availableBikes;
    bike.coordinate = coordinate;
    // save to array
    [self.arrayofBikes addObject:bike];

//    for (Bike *bike in self.arrayofBikes)
//    {
//        CLLocationDistance dis = [self getDistanceFromUserLocationToBikeStation:bike.coordinate];
//        bike.distance = dis;
//    }

}


#pragma mark - UITableView/UISearchBar

//Need to change the number of rows based on ifFiltered or not.
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isFiltered)
    {
        return self.filteredArrayOfBikes.count;
    }else
    {
        return self.arrayofBikes.count;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    Bike *bike = [self.arrayofBikes objectAtIndex:indexPath.row];
    cell.textLabel.text = bike.bikeName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", bike.numberOfBikes];
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    //get data object

     NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    [self.arrayofBikes objectAtIndex:indexPath.row];
    Bike *bike = [self.arrayofBikes objectAtIndex:indexPath.row];
    MapViewController *mapVC = segue.destinationViewController;

    mapVC.bike = bike;
    for (Bike *bike in self.arrayofBikes)
    {
        mapVC.bikeAnnotation.coordinate = bike.coordinate;

    }
}

#pragma Mark SEARCH AND SORTING

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (self.searchBar.text.length == 0)
    {
        self.isFiltered = NO;
    }else
    {
        self.isFiltered = YES;
        self.filteredArrayOfBikes = [NSMutableArray new];
        for (Bike *bike in self.arrayofBikes)
        {
            NSRange nameRange = [bike.bikeName rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
            if (nameRange.location != NSNotFound)
            {
                [self.filteredArrayOfBikes addObject:bike];
            }
        }
    }
    [self.tableView reloadData];
}

//-(CLLocationDistance)getDistanceFromUserLocationToBikeStation:(CLLocationCoordinate2D *)bikeLocation
//{
//    for (Bike *bike in self.arrayofBikes)
//    {
////        CLLocation *location =  bike.
//        CLLocationDistance distance = [self.userLocation distanceFromLocation:<#(const CLLocation *)#>];
//        return distance;
//        NSLog(@"%f", distance);
//    }
//}


-(void)sortTableview
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"distance" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    NSArray *sortedArray = [self.arrayofBikes sortedArrayUsingDescriptors:sortDescriptors];
    self.isAscending = !self.isAscending;

    if (self.isFiltered)
    {
        sortedArray = [self.filteredArrayOfBikes sortedArrayUsingDescriptors:sortDescriptors];
        self.filteredArrayOfBikes = [NSMutableArray new];
        self.filteredArrayOfBikes = [NSMutableArray arrayWithArray:sortedArray];
    }else
    {
        sortedArray = [self.arrayofBikes sortedArrayUsingDescriptors:sortDescriptors];
        self.arrayofBikes = [NSMutableArray new];
        self.arrayofBikes = [NSMutableArray arrayWithArray:sortedArray];
    }
    [self.tableView reloadData];
}

@end
