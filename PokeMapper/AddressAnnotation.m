//
//  AddressAnnotation.m
//  PokeMapper
//
//  Created by Guillermo Moran on 7/23/16.
//  Copyright © 2016 Guillermo Moran. All rights reserved.
//

#import "AddressAnnotation.h"

@implementation AddressAnnotation
@synthesize coordinate;
@synthesize pokemonId = _pokemonId;

- (NSString *)subtitle {
    return _subtitletext;
}

- (NSString *)title {
    return _titletext;
}


-(void)setTitle:(NSString*)strTitle {
    self.titletext = strTitle;
}

-(void)setSubTitle:(NSString*)strSubTitle {
    self.subtitletext = strSubTitle;
}

-(void)setPokemonId:(NSString *)iden {
    _pokemonId = iden;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)c {
    
    self = [super init];
    
    if (self) {
        coordinate = c;
    }
    return self;
}

-(MKAnnotationView*)annotationView {
    MKAnnotationView* annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:_pokemonId];
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:@"https://ugc.pokevision.com/images/pokemon/%@.png", _pokemonId]]];
    
    annotationView.image = [UIImage imageWithData: imageData];
    //annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
    
}

@end