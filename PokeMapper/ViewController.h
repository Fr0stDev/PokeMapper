//
//  ViewController.h
//  PokeMapper
//
//  Created by Guillermo Moran on 7/22/16.
//  Copyright © 2016 Guillermo Moran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <MKMapViewDelegate> {
    
    
    IBOutlet MKMapView* pokeMapView;
    IBOutlet UIBarButtonItem* refreshButton;
    IBOutlet UIButton* centerButton;
    CLLocationCoordinate2D location;
    BOOL firstLaunch;
    BOOL mapIsCentered;
    BOOL canRefresh;
    
 
    
    NSString* imageURL;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated;
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated;
- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation;
- (BOOL)mapViewRegionDidChangeFromUserInteraction;
- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation;

- (void)viewDidLoad;
- (void)showCenterButton;
- (void)hideCenterButton;
- (void)allowRefresh;
- (void)showLoading;
- (void)hideLoading;
- (void)startRunLoop;
- (IBAction)centerMap:(id)sender;
- (void)showRefreshButton;
- (void)hideRefreshButton;
- (IBAction)refreshPokemon:(id)sender;
- (void)fetchJobId:(CLLocationCoordinate2D)locationCoordinate;
- (NSString *)timeFormatted:(int)totalSeconds;
- (void)scanForPokemon:(NSString*)scanUrl;

@property(nonatomic, retain) MKMapView* pokeMapView;


@end

