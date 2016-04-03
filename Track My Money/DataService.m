//
//  DataService.m
//  TrackMyCash
//
//  Created by Ray Tam on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataService.h"
#import "AppDelegate.h"

@implementation DataService

@synthesize managedObjectContext;

+ (id)sharedDataService {
	static DataService *inst;
	if(!inst){
		inst = [[DataService alloc] init]; 
        [inst setup];
	}	
	return inst;
}

- (void)setup
{

}

- (NSArray *)getDataObjectsOfType:(NSString *)type {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:type inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    return [managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (NSArray *)getIOUs {
    return [[self getDataObjectsOfType:@"IOU"] sortedArrayUsingSelector:@selector(compare:)];
}

-(IOU *)createNewIOUObject {
    return (IOU *)[NSEntityDescription insertNewObjectForEntityForName:@"IOU" inManagedObjectContext:managedObjectContext];
}

-(Person *)createNewPersonObject {
    return (Person *)[NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:managedObjectContext];
}

-(IOUPersonLink *)createNewIOUPersonLinkObject {
    return (IOUPersonLink *)[NSEntityDescription insertNewObjectForEntityForName:@"IOUPersonLink" inManagedObjectContext:managedObjectContext];
}

- (NSArray *)getPeople {
    return [[self getDataObjectsOfType:@"Person"] sortedArrayUsingSelector:@selector(compare:)];
}

- (Person *)getPersonWithName:(NSString *)aName {
    NSArray *people = [self getDataObjectsOfType:@"Person"];
    for(Person *p in people) {
        if([[p.name lowercaseString] isEqualToString:[aName lowercaseString]]) {
            return p;
        }
    }
    return nil;
}

-(void)clearDatabase {
    [self deleteAllObjects:@"Person"];
    [self deleteAllObjects:@"IOU"];
    [self deleteAllObjects:@"IOUPersonLink"];
    [self saveChanges];
}

- (void) deleteAllObjects: (NSString *) entityDescription  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *managedObject in items) {
        [managedObjectContext deleteObject:managedObject];
    }
}


-(void)deleteObject:(id)obj {
    [managedObjectContext deleteObject:obj];
}

- (NSError *)saveChanges {
    NSError *error;
    if(![managedObjectContext save:&error]) {
        NSLog(@"Error, saving %@", [error localizedDescription]);
        return error;
    }
    else
        return nil;
}

-(void)rollback {
    [managedObjectContext rollback];
}

-(void)reset {
    [managedObjectContext reset];
}

- (NSArray *)executeFetchRequestOnEntity:(NSString *)entityName
                               predicate:(NSPredicate *)predicate {
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext]];
    [fetch setPredicate:predicate];
    return [managedObjectContext executeFetchRequest:fetch error:nil];
}


#pragma mark Utility functions

- (NSDecimalNumber *)getTotalPaymentsMade {
    NSArray *ious = [self getIOUs];
    NSDecimalNumber *amount = [NSDecimalNumber zero];
    for(IOU *iou in ious) {
        for(IOUPersonLink *pl in iou.peopleLink) {
            if([pl.amountOwed floatValue] < 0) {
                amount = [amount decimalNumberByAdding:pl.amountPaid];
            }
        }
    }
    if([amount floatValue] < 0) {
        amount = [amount decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithInt:-1]];
    }
    return amount;
}

- (NSDecimalNumber *)getTotalPaymentsReceived {
    NSArray *ious = [self getIOUs];
    NSDecimalNumber *amount = [NSDecimalNumber zero];
    for(IOU *iou in ious) {
        for(IOUPersonLink *pl in iou.peopleLink) {
            if([pl.amountOwed floatValue] > 0) {
                amount = [amount decimalNumberByAdding:pl.amountPaid];
            }
        }
    }
    return amount;
}



@end
