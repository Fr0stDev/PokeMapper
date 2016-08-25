//
//  PMPokedex.m
//  PokeMapper
//
//  Created by Guillermo Moran on 7/23/16.
//  Copyright © 2016 Guillermo Moran. All rights reserved.
//

#import "PMPokedex.h"
#import <Foundation/Foundation.h>

@implementation PMPokedex

+(NSString*)pokemonNameWithID:(NSString*)num {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"pokedex" ofType:@"json"];
    NSString *pokeJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSData* data = [pokeJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonParsingError;
    NSDictionary *pokeDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
    
    NSString* pokemonName = [pokeDict valueForKey:num];
    
    return pokemonName;
    
}

@end