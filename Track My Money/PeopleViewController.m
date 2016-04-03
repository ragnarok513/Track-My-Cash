//
//  PeopleViewController.m
//  Track My Money
//
//  Created by Raymond Tam on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PeopleViewController.h"
#import "PersonDetailsViewController.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "Person.h"
#import "CustomCell.h"
#import "FilterView.h"
#import "SettingsViewController.h"

@implementation PeopleViewController {
    NSMutableArray *listOfPeople;
    UITableView *tblPeople;
    BOOL adInView;
    BOOL filterIsExpanded;
}
@synthesize adBanner;

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"People";
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
        
        // Do any additional setup after loading the view from its nib.
        
        /// *** SETTINGS BUTTON *** ///
        UIImage *imgSettings = [UIImage imageNamed:@"basic2-298.png"];
        UIBarButtonItem *btnSettings = [[UIBarButtonItem alloc] initWithImage:imgSettings style:UIBarButtonItemStyleBordered target:self action:@selector(showSettings)];
        self.navigationItem.leftBarButtonItem = btnSettings;
        //*** FILTERS ***//
        filterView = [[FilterView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, FILTERBAR_HEIGHT) withClass:self];
        filterView.delegate = self;
        [self.view addSubview:filterView];
        
        tblPeople = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tblPeople.backgroundColor = [UIColor clearColor];
        tblPeople.backgroundView = nil;
        tblPeople.delegate = self;
        tblPeople.dataSource = self;
        [self.view addSubview:tblPeople];
        
        
        
        
        
        // Note that the GADBannerView checks its frame size to determine what size
        // creative to request.
        
        //Initialize the banner off the screen so that it animates up when displaying
        adInView = NO;
        if(IS_WIDESCREEN) {
            adBanner = [[[GADBannerView alloc] init] initWithAdSize:kGADAdSizeBanner origin:CGPointMake(0, 454)];
        }
        else {
            adBanner = [[[GADBannerView alloc] init] initWithAdSize:kGADAdSizeBanner origin:CGPointMake(0, 366)];
        }
        
        
        // Note: Edit SampleConstants.h to provide a definition for kSampleAdUnitID
        // before compiling.
        adBanner.adUnitID = MY_BANNER_UNIT_ID;
        adBanner.delegate = self;
        [adBanner setRootViewController:self];
        [self.view addSubview:adBanner];
        
        //*** AD DROPSHADOW ***//
        UIImage *imgDropShadow = [UIImage imageNamed:@"dropshadow.png"];
        imgViewDropShadow = [[UIImageView alloc] initWithImage:imgDropShadow];
        imgViewDropShadow.frame = CGRectMake(0, self.view.frame.size.height - TABBARHEIGHT - imgDropShadow.size.height, imgDropShadow.size.width, imgDropShadow.size.height);
        [self.view addSubview:imgViewDropShadow];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [adBanner loadRequest:[self createRequest]];
    
    [self populatePeopleWithFilterAndSort];
    [tblPeople reloadData];
    
    // reset my views
    [filterView resetView];
    filterIsExpanded = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark - UITableView delegate functions

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [listOfPeople count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    Person *p = [listOfPeople objectAtIndex:indexPath.row];
    
    NSDecimalNumber *balance = [p getOutstandingBalance];
    NSNumberFormatter *numformatter = [[NSNumberFormatter alloc] init];
    [numformatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numformatter setNegativeFormat:@"-¤#,##0.00"];
    
    cell.primaryLabel.text = p.name;
    int activeIOUs = 0;
    for(IOUPersonLink *pl in p.ious) {
        if([[pl getOutstandingBalance] floatValue] != 0) {
            activeIOUs++;
        }
    }
    
    if(activeIOUs == 1) {
        cell.subLabel.text = [NSString stringWithFormat:@"%i active IOU", activeIOUs];
    }
    else {
        cell.subLabel.text = [NSString stringWithFormat:@"%i active IOUs", activeIOUs];
    }
    cell.rightLabel.text = [NSString stringWithFormat:@"%@", [numformatter stringFromNumber:balance]];
    
    if([balance floatValue] < 0) {
        cell.rightLabel.textColor = [UIColor redColor];
    }
    else {
        cell.rightLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Person *p = [listOfPeople objectAtIndex:indexPath.row];
    PersonDetailsViewController *vc = [[PersonDetailsViewController alloc] initWithPerson:p];
    vc.navController = self.navigationController;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                   initWithTitle: @"Back" 
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark FilterViewDelegate functions

-(void)didStartExpandingWithDuration:(float)duration {
    filterIsExpanded = YES;
    [UIView animateWithDuration:duration
                     animations:^{
                         if(adInView) {
                             tblPeople.frame = CGRectMake(tblPeople.frame.origin.x, tblPeople.frame.origin.y + FILTERTABLE_HEIGHT, tblPeople.frame.size.width, self.view.frame.size.height - FILTERTABLE_HEIGHT - TABBARHEIGHT - FILTERBAR_HEIGHT + 43);
                         }
                         else {
                             tblPeople.frame = CGRectMake(tblPeople.frame.origin.x, tblPeople.frame.origin.y + FILTERTABLE_HEIGHT, tblPeople.frame.size.width, self.view.frame.size.height - FILTERTABLE_HEIGHT - TABBARHEIGHT - FILTERBAR_HEIGHT + 92); // not sure what changed my view.frame by 92 pixels
                         }
                     }]; 
}

-(void)didStartCollapsingWithDuration:(float)duration {
    filterIsExpanded = NO;
    [UIView animateWithDuration:duration
                     animations:^{
                         if(adInView) {
                             tblPeople.frame = CGRectMake(0, FILTERBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - TABBARHEIGHT - FILTERBAR_HEIGHT + 43);
                         }
                         else {
                             tblPeople.frame = CGRectMake(0, FILTERBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - TABBARHEIGHT + 63); // not sure what changed my view.frame by 63 pixels
                         }
                     }]; 
}

-(void)filterOrSortDidChange {
    [self populatePeopleWithFilterAndSort];
    [tblPeople reloadData];
}

#pragma mark - Filter Helper functions

-(void)populatePeopleWithFilterAndSort {
    // populate the iou list and filter it with current filter and sort
    NSArray *allPeople = [[DataService sharedDataService] getPeople];
    listOfPeople = [[NSMutableArray alloc] init];
    
    // filter first
    switch((int)filterView.currentFilter) {
        case AllPeople:
            listOfPeople = [NSMutableArray arrayWithArray:allPeople];
            break;
        case WithActiveIOUs:
            for(Person *p in allPeople) {
                for(IOUPersonLink *pl in p.ious) {
                    if([[pl.iou getOutstandingBalance] floatValue] != 0) {
                        [listOfPeople addObject:p];
                        break;
                    }
                }
            }
            break;
        case WithNoActiveIOUs:
            for(Person *p in allPeople) {
                BOOL hasActive = NO;
                for(IOUPersonLink *pl in p.ious) {
                    if([[pl.iou getOutstandingBalance] floatValue] != 0) {
                        hasActive = YES;
                        break;
                    }
                }
                if(!hasActive) {
                    [listOfPeople addObject:p];
                }
            }
            break;
        case OwesMeMoney:
        {
            for(Person *p in allPeople) {
                NSDecimalNumber *balance = [NSDecimalNumber zero];
                for(IOUPersonLink *pl in p.ious) {
                    if([pl.amountOwed floatValue] > 0) {
                        balance = [balance decimalNumberByAdding:[[pl getAbsAmountOwed] decimalNumberBySubtracting:pl.amountPaid]];
                    }
                    else {
                        balance = [balance decimalNumberBySubtracting:[[pl getAbsAmountOwed] decimalNumberBySubtracting:pl.amountPaid]];
                    }
                }
                if([balance floatValue] > 0) {
                    [listOfPeople addObject:p];
                }
            }
            break;
        }
        case IOweMoney:
        {
            for(Person *p in allPeople) {
                NSDecimalNumber *balance = [NSDecimalNumber zero];
                for(IOUPersonLink *pl in p.ious) {
                    if([pl.amountOwed floatValue] > 0) {
                        balance = [balance decimalNumberByAdding:[[pl getAbsAmountOwed] decimalNumberBySubtracting:pl.amountPaid]];
                    }
                    else {
                        balance = [balance decimalNumberBySubtracting:[[pl getAbsAmountOwed] decimalNumberBySubtracting:pl.amountPaid]];
                    }
                }
                if([balance floatValue] < 0) {
                    [listOfPeople addObject:p];
                }
            }
            break;
        }
    }
    
    // now sort
    switch((int)filterView.currentSort) {
        case Name:
            listOfPeople = [NSMutableArray arrayWithArray:[listOfPeople sortedArrayUsingComparator: ^(id a, id b) {
                NSString *x = ((Person *)a).name;
                NSString *y = ((Person *)b).name;
                return [x compare:y];
            }]];
            break;
        case MostActiveIOUs:
            listOfPeople = [NSMutableArray arrayWithArray:[listOfPeople sortedArrayUsingComparator: ^(id a, id b) {
                NSNumber *x = [NSNumber numberWithInt:0];
                for(IOUPersonLink *pl in ((Person *)a).ious) {
                    if([[pl.iou getOutstandingBalance] floatValue] != 0) {
                        x = [NSNumber numberWithInt:([x intValue] + 1)];
                    }
                }
                NSNumber *y = [NSNumber numberWithInt:0];
                for(IOUPersonLink *pl in ((Person *)b).ious) {
                    if([[pl.iou getOutstandingBalance] floatValue] != 0) {
                        y = [NSNumber numberWithInt:([y intValue] + 1)];
                    }
                }
                return [y compare:x];
            }]];
            break;
        case LargestBalance:
            listOfPeople = [NSMutableArray arrayWithArray:[listOfPeople sortedArrayUsingComparator: ^(id a, id b) {
                NSDecimalNumber *x = [NSDecimalNumber zero];
                NSDecimalNumber *y = [NSDecimalNumber zero];
                for(IOUPersonLink *pl in ((Person*)a).ious) {
                    if([pl.amountOwed floatValue] < 0) {
                        x = [x decimalNumberBySubtracting:[[pl getAbsAmountOwed] decimalNumberBySubtracting:pl.amountPaid]];
                    }
                    else {
                        x = [x decimalNumberByAdding:[[pl getAbsAmountOwed] decimalNumberBySubtracting:pl.amountPaid]];
                    }
                }
                for(IOUPersonLink *pl in ((Person*)b).ious) {
                    if([pl.amountOwed floatValue] < 0) {
                        y = [y decimalNumberBySubtracting:[[pl getAbsAmountOwed] decimalNumberBySubtracting:pl.amountPaid]];
                    }
                    else {
                        y = [y decimalNumberByAdding:[[pl getAbsAmountOwed] decimalNumberBySubtracting:pl.amountPaid]];
                    }
                }
                return [y compare:x];
            }]];
            break;
        case SmallestBalance:
            listOfPeople = [NSMutableArray arrayWithArray:[listOfPeople sortedArrayUsingComparator: ^(id a, id b) {
                NSDecimalNumber *x = [NSDecimalNumber zero];
                NSDecimalNumber *y = [NSDecimalNumber zero];
                for(IOUPersonLink *pl in ((Person*)a).ious) {
                    if([pl.amountOwed floatValue] < 0) {
                        x = [x decimalNumberBySubtracting:[[pl getAbsAmountOwed] decimalNumberBySubtracting:pl.amountPaid]];
                    }
                    else {
                        x = [x decimalNumberByAdding:[[pl getAbsAmountOwed] decimalNumberBySubtracting:pl.amountPaid]];
                    }
                }
                for(IOUPersonLink *pl in ((Person*)b).ious) {
                    if([pl.amountOwed floatValue] < 0) {
                        y = [y decimalNumberBySubtracting:[[pl getAbsAmountOwed] decimalNumberBySubtracting:pl.amountPaid]];
                    }
                    else {
                        y = [y decimalNumberByAdding:[[pl getAbsAmountOwed] decimalNumberBySubtracting:pl.amountPaid]];
                    }
                }
                return [x compare:y];
            }]];
            break;
    }
}

#pragma mark - Settings

-(void)showSettings {
    SettingsViewController *vc = [[SettingsViewController alloc] init];
    [self presentModalViewController:vc animated:YES];
}


#pragma mark GADRequest generation

// Here we're creating a simple GADRequest and whitelisting the simulator
// and two devices for test ads. You should request test ads during development
// to avoid generating invalid impressions and clicks.
- (GADRequest *)createRequest {
    GADRequest *request = [GADRequest request];
    //request.testing = YES;

    
    return request;
}

#pragma mark GADBannerViewDelegate impl

// Since we've received an ad, let's go ahead and set the frame to display it.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    adInView = YES;
    [UIView animateWithDuration:1.0f animations:^ {
        adView.frame = CGRectMake(0, self.view.frame.size.height - adView.frame.size.height, adView.frame.size.width, adView.frame.size.height);
        adView.backgroundColor = [UIColor blackColor];
        if(IS_WIDESCREEN ) {
            imgViewDropShadow.frame = CGRectMake(0, 399, imgViewDropShadow.frame.size.width, 6);
        }
        else {
            imgViewDropShadow.frame = CGRectMake(0, 311, imgViewDropShadow.frame.size.width, 6);
        }
        
        if(!filterIsExpanded) {
            tblPeople.frame = CGRectMake(0, FILTERBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - TABBARHEIGHT - FILTERBAR_HEIGHT + 43);
        }
        else {
            tblPeople.frame = CGRectMake(tblPeople.frame.origin.x, FILTERTABLE_HEIGHT + FILTERBAR_HEIGHT, tblPeople.frame.size.width, self.view.frame.size.height - FILTERTABLE_HEIGHT - TABBARHEIGHT - FILTERBAR_HEIGHT + 43);
        }
    }];
}

- (void)adView:(GADBannerView *)view
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}


@end
