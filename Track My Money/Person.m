//
//  Person.m
//  TrackMyCash
//
//  Created by Ray Tam on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Person.h"
#import "IOUPersonLink.h"


@implementation Person

@dynamic name;
@dynamic ious;

-(NSDecimalNumber *)getOutstandingBalance {
    NSDecimalNumber *balance = [[NSDecimalNumber alloc] initWithInt:0];
    for(IOUPersonLink *pl in self.ious) {
        balance = [balance decimalNumberByAdding:[pl getOutstandingBalance]];
    }
    return balance;
}

-(NSComparisonResult)compare:(Person *)person {
    return [[person getOutstandingBalance] compare:[self getOutstandingBalance]];
}


@end
