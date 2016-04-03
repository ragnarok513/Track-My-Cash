//
//  Person.h
//  TrackMyCash
//
//  Created by Ray Tam on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IOUPersonLink;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *ious;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addIousObject:(IOUPersonLink *)value;
- (void)removeIousObject:(IOUPersonLink *)value;
- (void)addIous:(NSSet *)values;
- (void)removeIous:(NSSet *)values;

-(NSDecimalNumber *)getOutstandingBalance;

@end
