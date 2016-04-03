//
//  PersonDetailsViewController.m
//  TrackMyCash
//
//  Created by Ray Tam on 8/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PersonDetailsViewController.h"
#import "CustomIOUCell.h"
#import "FilterView.h"
#import "PaymentViewController.h"

@interface PersonDetailsViewController () {
    NSMutableArray *pls;
}
@end

@implementation PersonDetailsViewController

@synthesize navController;

#pragma mark - View Lifecycle

- (id)initWithPerson:(Person *)person {
    self = [super init];
    if (self) {
        // Custom initialization
        myPerson = person;
        self.title = person.name;
        
        // set background
        [self.view setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
        
        //*** FILTERS ***//
        filterView = [[FilterView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, FILTERBAR_HEIGHT) withClass:self];
        filterView.delegate = self;
        [self.view addSubview:filterView];
        
        tblIOUs = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tblIOUs.backgroundColor = [UIColor clearColor];
        tblIOUs.backgroundView = nil;
        tblIOUs.delegate = self;
        tblIOUs.dataSource = self;
        [self.view addSubview:tblIOUs];
        
        //*** DROPSHADOW ***//
        UIImage *imgDropShadow = [UIImage imageNamed:@"dropshadow.png"];
        UIImageView *imgViewDropShadow = [[UIImageView alloc] initWithImage:imgDropShadow];
        imgViewDropShadow.frame = CGRectMake(0, self.view.frame.size.height - TABBARHEIGHT - imgDropShadow.size.height, imgDropShadow.size.width, imgDropShadow.size.height);
        [self.view addSubview:imgViewDropShadow];
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self populatePLsWithFilterAndSort];
    [tblIOUs reloadData];
    
    // reset my view
    [filterView resetView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDelegate functions

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return pls.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IOUPersonLink *pl = [pls objectAtIndex:indexPath.row];
    
    NSString *cellIdent = @"Cell";
    float percentPaid = [pl.amountPaid floatValue] / [[pl getAbsAmountOwed] floatValue];
    CustomIOUCell *cell = [[CustomIOUCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdent percentPaid:percentPaid];
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    
    cell.primaryLabel.text = pl.iou.title;
    if([pl.amountOwed floatValue] < 0) {
        cell.subLabel.text = [NSString stringWithFormat:@"I owe %@", [currencyFormatter stringFromNumber:[pl getAbsAmountOwed]]];
    }
    else {
        cell.subLabel.text = [NSString stringWithFormat:@"%@", [currencyFormatter stringFromNumber:[pl getAbsAmountOwed]]];
    }
    
    cell.rightSubLabel.text = [NSString stringWithFormat:@"%@ paid", [currencyFormatter stringFromNumber:pl.amountPaid]];
    if([pl.amountPaid floatValue] == [[pl getAbsAmountOwed] floatValue]) {
        // get date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"MM/dd/yyyy"];
        
        cell.rightLabel.text = [NSString stringWithFormat:@"paid %@", [dateFormatter stringFromDate:pl.paidOn]];
    }
    else {
        cell.rightLabel.text = @"";
    }

    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IOUPersonLink *pl = [pls objectAtIndex:indexPath.row];
    
    PaymentViewController *vc = [[PaymentViewController alloc] initWithIOU:pl.iou IOUPersonLink:pl lockPl:NO];
    vc.navController = self.navigationController;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                   initWithTitle: @"Cancel" 
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark FilterViewDelegate functions

-(void)didStartExpandingWithDuration:(float)duration {
    [UIView animateWithDuration:duration
                     animations:^{
                         tblIOUs.frame = CGRectMake(tblIOUs.frame.origin.x, tblIOUs.frame.origin.y + FILTERTABLE_HEIGHT, tblIOUs.frame.size.width, self.view.frame.size.height - FILTERTABLE_HEIGHT - TABBARHEIGHT + 63); // not sure what changed my view.frame by 63 pixels
                     }]; 
}

-(void)didStartCollapsingWithDuration:(float)duration {
    [UIView animateWithDuration:duration
                     animations:^{
                         tblIOUs.frame = CGRectMake(0, FILTERBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - TABBARHEIGHT + 63); // not sure what changed my view.frame by 63 pixels
                     }]; 
}

-(void)filterOrSortDidChange {
    [self populatePLsWithFilterAndSort];
    [tblIOUs reloadData];
}

#pragma mark - Filter Helper functions

-(void)populatePLsWithFilterAndSort {
    // populate the iou list and filter it with current filter and sort
    NSArray *allPLs = [[myPerson.ious allObjects] sortedArrayUsingSelector:@selector(compare:)];
    pls = [[NSMutableArray alloc] init];
    
    // filter first
    switch((int)filterView.currentFilter) {
        case AllIOUs:
            pls = [NSMutableArray arrayWithArray:allPLs];
            break;
        case DebtSettled:
            for(IOUPersonLink *pl in allPLs) {
                if([[pl.iou getOutstandingBalance] floatValue] == 0) {
                    [pls addObject:pl];
                }
            }
            break;
        case DebtUnsettled:
            for(IOUPersonLink *pl in allPLs) {
                if([[pl.iou getOutstandingBalance] floatValue] != 0) {
                    [pls addObject:pl];
                }
            }
            break;
        case OwesMeMoney:
            for(IOUPersonLink *pl in allPLs) {
                if([pl.amountOwed floatValue] > 0) {
                    [pls addObject:pl];
                }
            }
            break;
        case IOweMoney:
            for(IOUPersonLink *pl in allPLs) {
                if([pl.amountOwed floatValue] < 0) {
                    [pls addObject:pl];
                }
            }
            break;
    }
    
    // now sort
    switch((int)filterView.currentSort) {
        case Title:
            pls = [NSMutableArray arrayWithArray:[pls sortedArrayUsingComparator: ^(id a, id b) {
                NSString *x = ((IOUPersonLink*)a).iou.title;
                NSString *y = ((IOUPersonLink *)b).iou.title;
                return [x compare:y];
            }]];
            break;
        case LargestBalance:
            pls = [NSMutableArray arrayWithArray:[pls sortedArrayUsingComparator: ^(id a, id b) {
                NSDecimalNumber *x = ((IOUPersonLink*)a).amountOwed;
                NSDecimalNumber *y = ((IOUPersonLink*)b).amountOwed;
                return [y compare:x];
            }]];
            break;
        case SmallestBalance:
            pls = [NSMutableArray arrayWithArray:[pls sortedArrayUsingComparator: ^(id a, id b) {
                NSDecimalNumber *x = ((IOUPersonLink*)a).amountOwed;
                NSDecimalNumber *y = ((IOUPersonLink*)b).amountOwed;
                return [x compare:y];
            }]];
            break;
        case Paid:
            pls = [NSMutableArray arrayWithArray:[pls sortedArrayUsingComparator: ^(id a, id b) {
                NSNumber *x = [NSNumber numberWithBool:[[((IOUPersonLink*)a) getAbsAmountOwed] floatValue] == [((IOUPersonLink*)a).amountPaid floatValue]];
                NSNumber *y = [NSNumber numberWithBool:[[((IOUPersonLink*)b) getAbsAmountOwed] floatValue] == [((IOUPersonLink*)b).amountPaid floatValue]];
                return [y compare:x];
            }]];
            break;
        case Unpaid:
             pls = [NSMutableArray arrayWithArray:[pls sortedArrayUsingComparator: ^(id a, id b) {
             NSNumber *x = [NSNumber numberWithBool:[[((IOUPersonLink*)a) getAbsAmountOwed] floatValue] == [((IOUPersonLink*)a).amountPaid floatValue]];
             NSNumber *y = [NSNumber numberWithBool:[[((IOUPersonLink*)b) getAbsAmountOwed] floatValue] == [((IOUPersonLink*)b).amountPaid floatValue]];
                
                return [x compare:y];
            }]];
            break;
    }
}


@end
