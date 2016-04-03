//
//  IOUsViewController.m
//  Track My Money
//
//  Created by Raymond Tam on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IOUsViewController.h"
#import "EditIOUViewController.h"
#import "ViewIOUViewController.h"
#import "CustomIOUCell.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "FilterView.h"
#import "SettingsViewController.h"

@implementation IOUsViewController {
    NSMutableArray *ious;
    BOOL adInView;
    BOOL filterIsExpanded;
}


#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"IOUs";
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
        
        UIBarButtonItem *addIOUButton = [[UIBarButtonItem alloc] initWithTitle:@"Create IOU" style:UIBarButtonItemStylePlain target:self action:@selector(addIOU:)];
        self.navigationItem.rightBarButtonItem = addIOUButton;
        
        /// *** SETTINGS BUTTON *** ///
        UIImage *imgSettings = [UIImage imageNamed:@"basic2-298.png"];
        UIBarButtonItem *btnSettings = [[UIBarButtonItem alloc] initWithImage:imgSettings style:UIBarButtonItemStyleBordered target:self action:@selector(showSettings)];
        self.navigationItem.leftBarButtonItem = btnSettings;
    
        //*** FILTERS ***//
        filterView = [[FilterView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, FILTERBAR_HEIGHT) withClass:self];
        filterView.delegate = self;
        [self.view addSubview:filterView];
        
        //*** IOU TABLE ***//
        tblIOUs = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tblIOUs.backgroundColor = [UIColor clearColor];
        tblIOUs.backgroundView = nil;
        tblIOUs.delegate = self;
        tblIOUs.dataSource = self;
        [self.view addSubview:tblIOUs];
        
        // Do any additional setup after loading the view from its nib.
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

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    // load up IOUs
    [self populateIOUsWithFilterAndSort];
    [tblIOUs reloadData];
    [adBanner loadRequest:[self createRequest]];
    
    // reset my filter views (this will cause tblIOUs to readjust itself
    [filterView resetView];
    filterIsExpanded = NO;
}

- (void)addIOU:(id)sender
{
    [self loadAddIOUScreen];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)loadAddIOUScreen {
    EditIOUViewController *vc = [[EditIOUViewController alloc] initWithIOU:[[DataService sharedDataService] createNewIOUObject]];
    vc.navController = self.navigationController;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Cancel"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ious count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IOU *iou = [ious objectAtIndex:indexPath.row];
    NSDecimalNumber *unpaid = [NSDecimalNumber zero];
    NSDecimalNumber *paid = [NSDecimalNumber zero];

    for(IOUPersonLink *pl in iou.peopleLink) {
        unpaid = [unpaid decimalNumberByAdding:[pl getOutstandingBalance]];
        paid = [paid decimalNumberByAdding:pl.amountPaid];
    }
    
    // calculate total balance
    NSDecimalNumber *amountOwed = [[NSDecimalNumber alloc] initWithFloat:0.0f];;
    for (IOUPersonLink *link in iou.peopleLink) {
        amountOwed = [amountOwed decimalNumberByAdding:link.amountOwed];
    }
    
    NSDecimalNumber *amountOwedPos = amountOwed;
    if([amountOwedPos floatValue] < 0) {
        amountOwedPos = [amountOwedPos decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithInt:-1]];
    }
    
    float perc = [[paid decimalNumberByDividingBy:amountOwedPos] floatValue];
    
    static NSString *CellIdentifier = @"Cell";
    CustomIOUCell *cell = [[CustomIOUCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier percentPaid:perc];
    
    
    
    // grab title
    NSString *title = iou.title;
    
    

    NSNumberFormatter *numformatter = [[NSNumberFormatter alloc] init];
    [numformatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numformatter setNegativeFormat:@"-¤#,##0.00"];
    NSString *stringAmount = [numformatter stringFromNumber:amountOwed];
    
    // get date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"MM/dd/yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:iou.date];
    
    
    cell.primaryLabel.text = title;
    cell.subLabel.text = dateString;
    cell.rightLabel.text = stringAmount;
    if([amountOwed floatValue] < 0)
        cell.rightLabel.textColor = [UIColor redColor];
    else {
        cell.rightLabel.textColor = [UIColor blackColor];
    }
    cell.rightSubLabel.text = [NSString stringWithFormat:@"%@ paid", [numformatter stringFromNumber:paid]];
    

    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ViewIOUViewController *vc = [[ViewIOUViewController alloc] initWithIOU:[ious objectAtIndex:indexPath.row]];
    vc.navController = self.navigationController;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                   initWithTitle: @"Back" 
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:vc animated:YES];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        // show alert, can't delete the only person
        UIAlertView *alrtConfirmDelete = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this IOU?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alrtConfirmDelete.tag = indexPath.row;
        [alrtConfirmDelete show];
    }
}

#pragma mark - UIAlertViewDelegate functions

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) { // confirmed delete
        IOU* currIOU = [ious objectAtIndex:alertView.tag];
        for(IOUPersonLink *pl in currIOU.peopleLink) {
            [[DataService sharedDataService] deleteObject:pl];
        }
        [[DataService sharedDataService] deleteObject:currIOU];
        [[DataService sharedDataService] saveChanges];
        [self populateIOUsWithFilterAndSort];
        [tblIOUs reloadData];
    }
}

#pragma mark - FilterViewDelegate functions

-(void)didStartExpandingWithDuration:(float)duration {
    filterIsExpanded = YES;
    [UIView animateWithDuration:duration
                     animations:^{
                         if(adInView) {
                             tblIOUs.frame = CGRectMake(tblIOUs.frame.origin.x, FILTERTABLE_HEIGHT + FILTERBAR_HEIGHT, tblIOUs.frame.size.width, self.view.frame.size.height - FILTERTABLE_HEIGHT - TABBARHEIGHT - FILTERBAR_HEIGHT + 43);
                         }
                         else {
                             tblIOUs.frame = CGRectMake(tblIOUs.frame.origin.x, FILTERTABLE_HEIGHT + FILTERBAR_HEIGHT, tblIOUs.frame.size.width, self.view.frame.size.height - FILTERTABLE_HEIGHT - TABBARHEIGHT - FILTERBAR_HEIGHT + 93); // not sure what changed my view.frame by 93 pixels
                         }
                     }]; 
}

-(void)didStartCollapsingWithDuration:(float)duration {
    filterIsExpanded = NO;
    [UIView animateWithDuration:duration
                     animations:^{
                         if(adInView) {
                             tblIOUs.frame = CGRectMake(0, FILTERBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - TABBARHEIGHT - FILTERBAR_HEIGHT + 43);
                         }
                         else {
                             tblIOUs.frame = CGRectMake(0, FILTERBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - TABBARHEIGHT - FILTERBAR_HEIGHT + 93); // not sure what changed my view.frame by 93 pixels
                         }
                     }]; 
}

-(void)filterOrSortDidChange {
    [self populateIOUsWithFilterAndSort];
    [tblIOUs reloadData];
}

#pragma mark - Filter Helper functions

-(void)populateIOUsWithFilterAndSort {
    // populate the iou list and filter it with current filter and sort
    NSArray *allIOUs = [[DataService sharedDataService] getIOUs];
    ious = [[NSMutableArray alloc] init];
    
    // filter first
    switch((int)filterView.currentFilter) {
        case AllIOUs:
            ious = [NSMutableArray arrayWithArray:allIOUs];
            break;
        case ActiveIOUs:
            for(IOU *iou in allIOUs) {
                if([[iou getOutstandingBalance] floatValue] != 0) {
                    [ious addObject:iou];
                }
            }
            break;
        case CompletedIOUs:
            for(IOU *iou in allIOUs) {
                if([[iou getOutstandingBalance] floatValue] == 0) {
                    [ious addObject:iou];
                }
            }
            break;
        case ILoanedOutMoney:
            for(IOU *iou in allIOUs) {
                if([((IOUPersonLink*)[[iou.peopleLink allObjects] objectAtIndex:0]).amountOwed floatValue] > 0) {
                    [ious addObject:iou];
                }
            }
            break;
        case IBorrowedMoney:
            for(IOU *iou in allIOUs) {
                if([((IOUPersonLink*)[[iou.peopleLink allObjects] objectAtIndex:0]).amountOwed floatValue] < 0) {
                    [ious addObject:iou];
                }
            }
            break;
    }
    
    // now sort
    switch((int)filterView.currentSort) {
        case Title:
            ious = [NSMutableArray arrayWithArray:[ious sortedArrayUsingComparator: ^(id a, id b) {
                NSString *x = ((IOU *)a).title;
                NSString *y = ((IOU *)b).title;
                return [x caseInsensitiveCompare:y];
            }]];
            break;
        case Newest:
            ious = [NSMutableArray arrayWithArray:[ious sortedArrayUsingComparator: ^(id a, id b) {
                NSDate *x = ((IOU *)a).date;
                NSDate *y = ((IOU *)b).date;
                return [y compare:x];
            }]];
            break;
        case Oldest:
            ious = [NSMutableArray arrayWithArray:[ious sortedArrayUsingComparator: ^(id a, id b) {
                NSDate *x = ((IOU *)a).date;
                NSDate *y = ((IOU *)b).date;
                return [x compare:y];
            }]];
            break;
        case LargestBalance:
            ious = [NSMutableArray arrayWithArray:[ious sortedArrayUsingComparator: ^(id a, id b) {
                NSDecimalNumber *x = [NSDecimalNumber zero];
                NSDecimalNumber *y = [NSDecimalNumber zero];
                for(IOUPersonLink *pl in ((IOU*)a).peopleLink) {
                    x = [x decimalNumberByAdding:pl.amountOwed];
                }
                for(IOUPersonLink *pl in ((IOU*)b).peopleLink) {
                    y = [y decimalNumberByAdding:pl.amountOwed];
                }
                return [y compare:x];
            }]];
            break;
        case SmallestBalance:
            ious = [NSMutableArray arrayWithArray:[ious sortedArrayUsingComparator: ^(id a, id b) {
                NSDecimalNumber *x = [NSDecimalNumber zero];
                NSDecimalNumber *y = [NSDecimalNumber zero];
                for(IOUPersonLink *pl in ((IOU*)a).peopleLink) {
                    x = [x decimalNumberByAdding:pl.amountOwed];
                }
                for(IOUPersonLink *pl in ((IOU*)b).peopleLink) {
                    y = [y decimalNumberByAdding:pl.amountOwed];
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

#pragma mark - GADRequest generation

// Here we're creating a simple GADRequest and whitelisting the simulator
// and two devices for test ads. You should request test ads during development
// to avoid generating invalid impressions and clicks.
- (GADRequest *)createRequest {
    GADRequest *request = [GADRequest request];
    //request.testing = YES;
    
    return request;
}

#pragma mark - GADBannerViewDelegate impl

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
            tblIOUs.frame = CGRectMake(0, FILTERBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - TABBARHEIGHT - FILTERBAR_HEIGHT + 43);
        }
        else {
            tblIOUs.frame = CGRectMake(tblIOUs.frame.origin.x, FILTERTABLE_HEIGHT + FILTERBAR_HEIGHT, tblIOUs.frame.size.width, self.view.frame.size.height - FILTERTABLE_HEIGHT - TABBARHEIGHT - FILTERBAR_HEIGHT + 43);
        }
    }];
}

- (void)adView:(GADBannerView *)view
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}

@end
