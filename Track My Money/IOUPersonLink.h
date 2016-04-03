//
//  IOUPersonLink.h
//  TrackMyCash
//
//  Created by Ray Tam on 8/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IOU, Person;

@interface IOUPersonLink : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * amountOwed;
@property (nonatomic, retain) NSDecimalNumber * amountPaid;
@property (nonatomic, retain) NSDate * paidOn;
@property (nonatomic, retain) IOU *iou;
@property (nonatomic, retain) Person *person;

-(NSDecimalNumber *)getAbsAmountOwed;
-(NSDecimalNumber *)getOutstandingBalance;


@end
