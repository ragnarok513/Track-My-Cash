//
//  IOU.h
//  TrackMyCash
//
//  Created by Ray Tam on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IOUPersonLink;

@interface IOU : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *peopleLink;
@end

@interface IOU (CoreDataGeneratedAccessors)

- (void)addPeopleLinkObject:(IOUPersonLink *)value;
- (void)removePeopleLinkObject:(IOUPersonLink *)value;
- (void)addPeopleLink:(NSSet *)values;
- (void)removePeopleLink:(NSSet *)values;


- (NSDecimalNumber *)getTotalBalance;
- (NSDecimalNumber *)getOutstandingBalance;

@end
