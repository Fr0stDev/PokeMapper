//
//  AddressAnnotation.h
//  PokeMapper
//
//  Created by Guillermo Moran on 7/23/16.
//  Copyright © 2016 Guillermo Moran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface AddressAnnotation : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

@property (readwrite, retain) NSString *titletext;
@property (readwrite, retain) NSString *subtitletext;
@property (nonatomic, retain) NSString *pokemonId;


-(id)initWithCoordinate:(CLLocationCoordinate2D) c;
-(void)setTitle:(NSString*)strTitle;
-(void)setSubTitle:(NSString*)strSubTitle;
-(void)setPokemonId:(NSString *)iden;

-(MKAnnotationView*)annotationView;

@end