//
//  DataService.h
//  TrackMyCash
//
//  Created by Ray Tam on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataService : NSObject {
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (id)sharedDataService;
- (NSError *)saveChanges;
- (NSArray *)getIOUs;
- (IOU *)createNewIOUObject;
- (IOUPersonLink *)createNewIOUPersonLinkObject;
- (Person *)createNewPersonObject;
- (NSArray *)getPeople;
- (Person *)getPersonWithName:(NSString *)aName;
- (NSDecimalNumber *)getTotalPaymentsMade;
- (NSDecimalNumber *)getTotalPaymentsReceived;
- (void)clearDatabase;
- (void)deleteObject:(id)obj;
- (void)rollback;
- (void)reset;
- (NSArray *)executeFetchRequestOnEntity:(NSString *)entityName predicate:(NSPredicate *)predicate;

@end
