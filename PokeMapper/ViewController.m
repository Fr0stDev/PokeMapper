//
//  ViewController.m
//  PokeMapper
//
//  Created by Guillermo Moran on 7/22/16.
//  Copyright © 2016 Guillermo Moran. All rights reserved.
//

#import "ViewController.h"
#import "AddressAnnotation.h"
#import "PMPokedex.h"
#import "GifHUD.h"

//@interface MKMapView (k)
//-(void)_setShowsNightMode:(BOOL)meh;
//@end

@interface ViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation ViewController

@synthesize pokeMapView = _pokeMapView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
        
    UINavigationBar *myNav = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    [UINavigationBar appearance].barTintColor = [UIColor lightGrayColor];
    [self.view addSubview:myNav];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    _pokeMapView.delegate = self;
    _pokeMapView.showsUserLocation = YES;
    //[_pokeMapView _setShowsNightMode:YES];
    
    [GiFHUD setGifWithImageName:@"pika.gif"];
    
    firstLaunch = YES;
    
}

-(void)showCenterButton {
    [centerButton setHidden:NO];
}

-(void)hideCenterButton {
    [centerButton setHidden:YES];
}


-(void)allowRefresh {
    canRefresh = YES;
}

-(void)showLoading {
    [GiFHUD show];
}

-(void)hideLoading {
    [GiFHUD dismiss];
}

-(void)startRunLoop {
    //[self refreshPokemon:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(refreshPokemon:) userInfo:nil repeats:YES];
    
    
}



-(IBAction)centerMap:(id)sender{
    MKCoordinateRegion mapRegion;
    mapRegion.center = _pokeMapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.005;
    mapRegion.span.longitudeDelta = 0.005;
    
    [_pokeMapView setRegion:mapRegion animated: YES];
    
  
    [self hideCenterButton];
    
    mapIsCentered = YES;
}




-(void)showServerError {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Server Unavailable"
                                          message:@"Please try again later"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    [self hideLoading];
}

-(void)showRefreshButton {
    refreshButton.enabled = YES;
    
}

-(void)hideRefreshButton {
    refreshButton.enabled = NO;
    
    [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(showRefreshButton) userInfo:nil repeats:NO];
}



-(IBAction)refreshPokemon:(id)sender {
    
    if (!canRefresh && sender == nil) {
        //NSLog(@"No refresh yet!");
        return;
    }
    
    if ([[_pokeMapView annotations] count] > 0) {
        [_pokeMapView removeAnnotations:[_pokeMapView annotations]];
    }
    
    //[self fetchJobId:location];
    [self fetchJobId:[_pokeMapView centerCoordinate] ];
    [self showLoading];
    
    [self hideRefreshButton];
    canRefresh = NO;
    
    [NSTimer scheduledTimerWithTimeInterval:59.0f target:self selector:@selector(allowRefresh) userInfo:nil repeats:NO];
    
    
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    
    
    NSString * timeStampString = [NSString stringWithFormat:@"%i",totalSeconds];
    NSTimeInterval _interval=[timeStampString doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    
    
    return [NSString stringWithFormat:@"Disappears at %@",dateStr];
}

- (void)fetchJobId:(CLLocationCoordinate2D)locationCoordinate {
    
    NSString* baseURL = @"https://pokevision.com";
  
    //Get the job ID
    
    __block NSString* jobID;
    
    NSString* jobURL = [NSString stringWithFormat:@"%@/map/scan/%f/%f", baseURL,locationCoordinate.latitude,locationCoordinate.longitude];
    NSLog(@"%@", jobURL);
    
    
    NSURL *url = [NSURL URLWithString:jobURL];
    NSMutableURLRequest *jobIdRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
  
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:jobIdRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        
        
        
        if (error)
        {
            [self performSelectorOnMainThread:@selector(showServerError) withObject:nil waitUntilDone:YES];
            
        }
        else
        {
            NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
            
            NSError *jsonParsingError;
            NSDictionary *jobDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];

            jobID = [jobDict objectForKey:@"jobId"];
      
            
            NSLog(@"Job ID: %@", jobID);
            
            NSString* scanURL = [NSString stringWithFormat:@"%@/map/data/%f/%f/%@", baseURL,locationCoordinate.latitude,locationCoordinate.longitude, jobID];
            
            
       
            
            if (jobID) {
                [self scanForPokemon:scanURL];
                //[self performSelectorOnMainThread:@selector(scanForPokemon:) withObject:scanURL waitUntilDone:YES];
            }
            
            else {
                NSLog(@"error1");
                [self performSelectorOnMainThread:@selector(showServerError) withObject:nil waitUntilDone:YES];
                
            }
            
            
        }
    }];

   
}



-(void)scanForPokemon:(NSString*)scanUrl {
    NSLog(@"Begin Scan...");
    
    //Scan for pokemon using the job id
    __block NSString* jobStatus = @"in_progress";
    
    NSLog(@"%@", scanUrl);
    
    int loopCount = 0;
    
    while (jobStatus && loopCount < 100) {
        
        NSLog(@"Loop: %i", loopCount);
        
        // Send a synchronous request
        NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:scanUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        
        if (error) {
             [self performSelectorOnMainThread:@selector(showServerError) withObject:nil waitUntilDone:YES];
        }
        
        if (error == nil)
        {
            //
            
            NSError *jsonParsingError;
            NSDictionary *jobDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            
            @try {
                jobStatus = [jobDict objectForKey:@"jobStatus"];
            } @catch (NSException *exception) {
                NSLog(@"No job status");
            }
            
            if (jobStatus) {
                NSLog(@"Job Status: %@", jobStatus);
                
                if (![jobStatus isEqualToString:@"in_progress"]) {
                    NSLog(@"error2");
                    //[self showServerError];
                    [self performSelectorOnMainThread:@selector(showServerError) withObject:nil waitUntilDone:YES];
                    break;
                }
            }
            else {
                //Parse pokemon data
                
                NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
                
                NSError *jsonParsingError;
                NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
                
        
                
                NSArray* pokemonIds = [responseDict valueForKeyPath:@"pokemon.pokemonId"];
                NSLog(@"Pokemon IDs: %@", pokemonIds);
                
                NSArray* latitudes = [responseDict valueForKeyPath:@"pokemon.latitude"];
                NSArray* longitudes = [responseDict valueForKeyPath:@"pokemon.longitude"];
                
                NSArray* expiration_time = [responseDict valueForKeyPath:@"pokemon.expiration_time"];
                NSLog(@"Pokemon Coordinates: %@, %@", latitudes, longitudes);
                
                
                
                float numberOfPokemon = [pokemonIds count];
                
                int i = 0;
                
                while (i < numberOfPokemon) {
                    
                    CLLocationCoordinate2D  ctrpoint;
                    ctrpoint.latitude = [[latitudes objectAtIndex:i] doubleValue];
                    ctrpoint.longitude = [[longitudes objectAtIndex:i] doubleValue];
                
                    NSString* pokemonId = [[pokemonIds objectAtIndex:i] stringValue];
                    
                    AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:ctrpoint];
                    [addAnnotation setTitle:[PMPokedex pokemonNameWithID:pokemonId]];
                    [addAnnotation setSubTitle:[self timeFormatted:[[expiration_time objectAtIndex:i] intValue]]];
                    [addAnnotation setPokemonId:pokemonId];
                    //[_pokeMapView addAnnotation:addAnnotation];
                    [_pokeMapView performSelectorOnMainThread:@selector(addAnnotation:) withObject:addAnnotation waitUntilDone:YES];
                    
                    
                    NSLog(@"Added Pin at: %f, %f", ctrpoint.latitude, ctrpoint.longitude);
                    
                    i++;
                    
                }
                
            }
            
        }
        
        if (loopCount == 99) {
            [self performSelectorOnMainThread:@selector(showServerError) withObject:nil waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:YES];
        }
        
        loopCount++;
    }
    [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:YES];
}

#pragma mark MapView Delegate

static BOOL mapChangedFromUserInteraction = NO;

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    mapChangedFromUserInteraction = [self mapViewRegionDidChangeFromUserInteraction];
    
    if (mapChangedFromUserInteraction) {
        mapIsCentered = NO;
        [self showCenterButton];
    }
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    CLLocationCoordinate2D centre = [_pokeMapView centerCoordinate];
    
    location = centre;
    
    if (mapChangedFromUserInteraction) {
        mapIsCentered = NO;
        [self showCenterButton];
    }
    
    
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    
    //CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    
    //NSLog(@"%f, %f", location.latitude, location.longitude);
    
    region.span = span;
    region.center = location;
    
    if (firstLaunch) {
        canRefresh = YES;
        
        firstLaunch = NO;
        mapIsCentered = YES;
        [aMapView setRegion:region animated:YES];
        
        [self showLoading];
        [self hideCenterButton];
        [self fetchJobId:location]; //scan first
        
        
        [self startRunLoop]; //start autorefresh loop
    }
    
    if (mapIsCentered) {
        [aMapView setRegion:region animated:YES];
    }
    
}

- (BOOL)mapViewRegionDidChangeFromUserInteraction
{
    UIView *view = _pokeMapView.subviews.firstObject;
    //  Look through gesture recognizers to determine whether this region change is from user interaction
    for(UIGestureRecognizer *recognizer in view.gestureRecognizers) {
        if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateEnded) {
            return YES;
        }
    }
    
    return NO;
}

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[AddressAnnotation class]]) {
        AddressAnnotation* myLocation = (AddressAnnotation*)annotation;
        
        NSString* randomString = [NSString stringWithFormat:@"%i", arc4random_uniform(1000)];
        
        MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:randomString];
        
        if (annotationView == nil) {
            annotationView = myLocation.annotationView;
        }
        else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    return nil;
}

#pragma mark Other Stuff

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
