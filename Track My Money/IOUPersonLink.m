//
//  IOUPersonLink.m
//  TrackMyCash
//
//  Created by Ray Tam on 8/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IOUPersonLink.h"
#import "IOU.h"
#import "Person.h"


@implementation IOUPersonLink

@dynamic amountOwed;
@dynamic amountPaid;
@dynamic paidOn;
@dynamic iou;
@dynamic person;

-(NSDecimalNumber *)getAbsAmountOwed {
    NSDecimalNumber *tempNum = (NSDecimalNumber *)[self.amountOwed copy];
    if([tempNum floatValue] < 0) {
        tempNum = [tempNum decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithInt:-1]];
    }
    return tempNum;
}

-(NSDecimalNumber *)getOutstandingBalance {
    NSDecimalNumber *amountOwed = [NSDecimalNumber zero];
    if([self.amountOwed floatValue] < 0) {
        amountOwed = [self.amountOwed decimalNumberByAdding:self.amountPaid];
    }
    else {
        amountOwed = [self.amountOwed decimalNumberBySubtracting:self.amountPaid];
    }
    
    return amountOwed;
}

-(NSComparisonResult)compare:(IOUPersonLink *)pl {
    return [self.person.name compare:pl.person.name];
}

@end
