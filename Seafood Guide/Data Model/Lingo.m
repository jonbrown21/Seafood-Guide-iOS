//
//  Lingo.m
//  Seafood Guide
//
//  Created by Jon on 7/13/15.
//  Copyright (c) 2015 Jon Brown Designs. All rights reserved.
//

#import "Lingo.h"


@implementation Lingo

@dynamic linknews;
@dynamic descnews;
@dynamic titlenews;
@dynamic imageurl;

- (NSString *)uppercaseFirstLetterOfName {
    NSString *aString = [[self valueForKey:@"titlenews"] uppercaseString];
    
    // support UTF-16:
    NSString *stringToReturn = [aString substringWithRange:[aString rangeOfComposedCharacterSequenceAtIndex:0]];
    
    // OR no UTF-16 support:
    //NSString *stringToReturn = [aString substringToIndex:1];
    
    return stringToReturn;
}

@end