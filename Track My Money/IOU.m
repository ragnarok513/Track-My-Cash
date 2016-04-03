//
//  IOU.m
//  TrackMyCash
//
//  Created by Ray Tam on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IOU.h"
#import "IOUPersonLink.h"


@implementation IOU

@dynamic date;
@dynamic notes;
@dynamic title;
@dynamic peopleLink;

-(NSComparisonResult)compare:(IOU *)iou {
    return [iou.date compare:self.date];
}

-(NSDecimalNumber *)getTotalBalance {
    NSDecimalNumber *total = [NSDecimalNumber zero];
    for(IOUPersonLink *pl in self.peopleLink) {
        total = [total decimalNumberByAdding:pl.amountOwed];
    }
    return total;
}

-(NSDecimalNumber *)getOutstandingBalance {
    NSDecimalNumber *total = [NSDecimalNumber zero];
    for(IOUPersonLink *pl in self.peopleLink) {
        NSDecimalNumber *plTotal = [NSDecimalNumber zero];
        plTotal = [[pl getAbsAmountOwed] decimalNumberBySubtracting:pl.amountPaid];
        total =  [total decimalNumberByAdding:plTotal];
    }
    return total;
}



@end
