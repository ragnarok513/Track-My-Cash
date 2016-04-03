//
//  SummaryViewController.m
//  Track My Money
//
//  Created by Raymond Tam on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SummaryViewController.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "EditIOUViewController.h"
#import "SettingsViewController.h"

@implementation SummaryViewController {
    
}

@synthesize adBanner, lblMoneyBorrowed, lblMoneyBorrowedAmount, lblMoneyLent, lblMoneyLentAmount, lblTotalBalance, lblTotalBalanceAmount, lblNumOfActiveIOUs, lblNumOfAllIOUs, lblNumOfActivePeople, lblMoney, lblIOUs, lblPeople;

#pragma mark - View lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = @"Summary";
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
        
        UIBarButtonItem *createIOUButton = [[UIBarButtonItem alloc] initWithTitle:@"Create IOU" style:UIBarButtonItemStylePlain target:self action:@selector(createIOUTapped:)];
        self.navigationItem.rightBarButtonItem = createIOUButton;
        
        /// *** SETTINGS BUTTON *** ///
        UIImage *imgSettings = [UIImage imageNamed:@"basic2-298.png"];
        UIBarButtonItem *btnSettings = [[UIBarButtonItem alloc] initWithImage:imgSettings style:UIBarButtonItemStyleBordered target:self action:@selector(showSettings)];
        self.navigationItem.leftBarButtonItem = btnSettings;

        
        // MONEY SECTION
        
        lblMoney = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, self.view.frame.size.width - 40, 30)];
        lblMoney.text = @"MONEY";
        lblMoney.font = DEFAULT_FONT_BOLD(DEFAULT_HEADER_SIZE + 8);
        lblMoney.backgroundColor = [UIColor clearColor];
        [self.view addSubview:lblMoney];
        
        lblMoneyLent = [[UILabel alloc] initWithFrame:CGRectMake(20, 35, 130, 30)];
        lblMoneyLent.font = DEFAULT_FONT(DEFAULT_HEADER_SIZE);
        lblMoneyLent.text = @"Money Lent:";
        lblMoneyLent.backgroundColor = [UIColor clearColor];
        [self.view addSubview:lblMoneyLent];
        
        lblMoneyLentAmount = [[UILabel alloc] initWithFrame:CGRectMake(135, 35, self.view.frame.size.width - 135 - 20, 30)];
        lblMoneyLentAmount.textAlignment = UITextAlignmentRight;
        lblMoneyLentAmount.backgroundColor = [UIColor clearColor];
        lblMoneyLentAmount.adjustsFontSizeToFitWidth = YES;
        lblMoneyLentAmount.font = DEFAULT_FONT(14);
        [self.view addSubview:lblMoneyLentAmount];
        
        lblPaymentsReceived = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, 170, 30)];
        lblPaymentsReceived.font = DEFAULT_FONT(DEFAULT_HEADER_SIZE);
        lblPaymentsReceived.text = @"Payments Received:";
        lblPaymentsReceived.backgroundColor = [UIColor clearColor];
        [self.view addSubview:lblPaymentsReceived];
        
        lblPaymentsReceivedAmount = [[UILabel alloc] initWithFrame:CGRectMake(175, 55, self.view.frame.size.width - 175 - 20, 30)];
        lblPaymentsReceivedAmount.textAlignment = UITextAlignmentRight;
        lblPaymentsReceivedAmount.backgroundColor = [UIColor clearColor];
        lblPaymentsReceivedAmount.adjustsFontSizeToFitWidth = YES;
        lblPaymentsReceivedAmount.font = DEFAULT_FONT(14);
        [self.view addSubview:lblPaymentsReceivedAmount];
        
        lblMoneyBorrowed = [[UILabel alloc] initWithFrame:CGRectMake(20, 75, 170, 30)];
        lblMoneyBorrowed.font = DEFAULT_FONT(DEFAULT_HEADER_SIZE);
        lblMoneyBorrowed.text = @"Money Borrowed:";
        lblMoneyBorrowed.backgroundColor = [UIColor clearColor];
        [self.view addSubview:lblMoneyBorrowed];
        
        lblMoneyBorrowedAmount = [[UILabel alloc] initWithFrame:CGRectMake(175, 75, self.view.frame.size.width - 175 - 20, 30)];
        lblMoneyBorrowedAmount.textAlignment = UITextAlignmentRight;
        lblMoneyBorrowedAmount.backgroundColor = [UIColor clearColor];
        lblMoneyBorrowedAmount.textColor = [UIColor blackColor];
        lblMoneyBorrowedAmount.adjustsFontSizeToFitWidth = YES;
        lblMoneyBorrowedAmount.font = DEFAULT_FONT(14);
        [self.view addSubview:lblMoneyBorrowedAmount];
        
        lblPaymentsMade = [[UILabel alloc] initWithFrame:CGRectMake(20, 95, 180, 30)];
        lblPaymentsMade.font = DEFAULT_FONT(DEFAULT_HEADER_SIZE);
        lblPaymentsMade.text = @"Payments Made By Me:";
        lblPaymentsMade.backgroundColor = [UIColor clearColor];
        [self.view addSubview:lblPaymentsMade];
        
        lblPaymentsMadeAmount = [[UILabel alloc] initWithFrame:CGRectMake(200, 95, self.view.frame.size.width - 200 - 20, 30)];
        lblPaymentsMadeAmount.textAlignment = UITextAlignmentRight;
        lblPaymentsMadeAmount.backgroundColor = [UIColor clearColor];
        lblPaymentsMadeAmount.adjustsFontSizeToFitWidth = YES;
        lblPaymentsMadeAmount.font = DEFAULT_FONT(14);
        [self.view addSubview:lblPaymentsMadeAmount];
        
        blackBar = [[UIView alloc] initWithFrame:CGRectMake(200, 123, self.view.frame.size.width - 200 - 20, 1)];
        blackBar.backgroundColor = [UIColor blackColor];
        [self.view addSubview:blackBar];
        
        lblTotalBalance = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 140, 30)];
        lblTotalBalance.font = DEFAULT_FONT(DEFAULT_HEADER_SIZE);
        lblTotalBalance.text = @"Total Balance:";
        lblTotalBalance.backgroundColor = [UIColor clearColor];
        [self.view addSubview:lblTotalBalance];
        
        lblTotalBalanceAmount = [[UILabel alloc] initWithFrame:CGRectMake(125, 120, self.view.frame.size.width - 125 - 20, 30)];
        lblTotalBalanceAmount.textAlignment = UITextAlignmentRight;
        lblTotalBalanceAmount.backgroundColor = [UIColor clearColor];
        lblTotalBalanceAmount.adjustsFontSizeToFitWidth = YES;
        lblTotalBalanceAmount.font = DEFAULT_FONT(14);
        [self.view addSubview:lblTotalBalanceAmount];
        
        // IOUS SECTION
        lblIOUs = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, self.view.frame.size.width - 40, 30)];
        lblIOUs.text = @"IOUs";
        lblIOUs.font = DEFAULT_FONT_BOLD(DEFAULT_HEADER_SIZE + 8);
        lblIOUs.backgroundColor = [UIColor clearColor];
        [self.view addSubview:lblIOUs];
        
        lblNumOfActiveIOUs = [[UILabel alloc] initWithFrame:CGRectMake(20, 173, self.view.frame.size.width - 40, 30)];
        lblNumOfActiveIOUs.font = DEFAULT_FONT(DEFAULT_HEADER_SIZE);
        lblNumOfActiveIOUs.backgroundColor = [UIColor clearColor];
        [self.view addSubview:lblNumOfActiveIOUs];
        
        lblNumOfAllIOUs = [[UILabel alloc] initWithFrame:CGRectMake(20, 193, self.view.frame.size.width - 40, 30)];
        lblNumOfAllIOUs.font = DEFAULT_FONT(DEFAULT_HEADER_SIZE);
        lblNumOfAllIOUs.backgroundColor = [UIColor clearColor];
        [self.view addSubview:lblNumOfAllIOUs];
        
        // PEOPLE SECTION
        lblPeople = [[UILabel alloc] initWithFrame:CGRectMake(20, 230, self.view.frame.size.width - 40, 30)];
        lblPeople.text = @"PEOPLE";
        lblPeople.font = DEFAULT_FONT_BOLD(DEFAULT_HEADER_SIZE + 8);
        lblPeople.backgroundColor = [UIColor clearColor];
        [self.view addSubview:lblPeople];
        
        lblNumOfActivePeople = [[UILabel alloc] initWithFrame:CGRectMake(20, 253, self.view.frame.size.width - 40, 50)];
        lblNumOfActivePeople.font = DEFAULT_FONT(DEFAULT_HEADER_SIZE);
        lblNumOfActivePeople.backgroundColor = [UIColor clearColor];
        lblNumOfActivePeople.numberOfLines = 2;
        [self.view addSubview:lblNumOfActivePeople];
        
        //*** WIDESCREEN COMPATIBILITY ***//
        if(IS_WIDESCREEN) {
            lblPaymentsReceived.frame = CGRectMake(lblPaymentsReceived.frame.origin.x, lblPaymentsReceived.frame.origin.y + 3, lblPaymentsReceived.frame.size.width, lblPaymentsReceived.frame.size.height);
            lblPaymentsReceivedAmount.frame = CGRectMake(lblPaymentsReceivedAmount.frame.origin.x, lblPaymentsReceivedAmount.frame.origin.y + 3, lblPaymentsReceivedAmount.frame.size.width, lblPaymentsReceivedAmount.frame.size.height);
            lblMoneyBorrowed.frame = CGRectMake(lblMoneyBorrowed.frame.origin.x, lblMoneyBorrowed.frame.origin.y + 6, lblMoneyBorrowed.frame.size.width, lblMoneyBorrowed.frame.size.height);
            lblMoneyBorrowedAmount.frame = CGRectMake(lblMoneyBorrowedAmount.frame.origin.x, lblMoneyBorrowedAmount.frame.origin.y + 6, lblMoneyBorrowedAmount.frame.size.width, lblMoneyBorrowedAmount.frame.size.height);
            lblPaymentsMade.frame = CGRectMake(lblPaymentsMade.frame.origin.x, lblPaymentsMade.frame.origin.y + 9, lblPaymentsMade.frame.size.width, lblPaymentsMade.frame.size.height);
            lblPaymentsMadeAmount.frame = CGRectMake(lblPaymentsMadeAmount.frame.origin.x, lblPaymentsMadeAmount.frame.origin.y + 9, lblPaymentsMadeAmount.frame.size.width, lblPaymentsMadeAmount.frame.size.height);
            blackBar.frame = CGRectMake(blackBar.frame.origin.x, blackBar.frame.origin.y + 12, blackBar.frame.size.width, blackBar.frame.size.height);
            lblTotalBalance.frame = CGRectMake(lblTotalBalance.frame.origin.x, lblTotalBalance.frame.origin.y + 15, lblTotalBalance.frame.size.width, lblTotalBalance.frame.size.height);
            lblTotalBalanceAmount.frame = CGRectMake(lblTotalBalanceAmount.frame.origin.x, lblTotalBalanceAmount.frame.origin.y + 15, lblTotalBalanceAmount.frame.size.width, lblTotalBalanceAmount.frame.size.height);
            
            
            lblIOUs.frame = CGRectMake(lblIOUs.frame.origin.x, lblIOUs.frame.origin.y + 50, lblIOUs.frame.size.width, lblIOUs.frame.size.height);
            lblNumOfActiveIOUs.frame = CGRectMake(lblNumOfActiveIOUs.frame.origin.x, lblNumOfActiveIOUs.frame.origin.y + 50, lblNumOfActiveIOUs.frame.size.width, lblNumOfActiveIOUs.frame.size.height);
            lblNumOfAllIOUs.frame = CGRectMake(lblNumOfAllIOUs.frame.origin.x, lblNumOfAllIOUs.frame.origin.y + 50, lblNumOfAllIOUs.frame.size.width, lblNumOfAllIOUs.frame.size.height);
            
            
            lblPeople.frame = CGRectMake(lblPeople.frame.origin.x, lblPeople.frame.origin.y + 80, lblPeople.frame.size.width, lblPeople.frame.size.height);
            lblNumOfActivePeople.frame = CGRectMake(lblNumOfActivePeople.frame.origin.x, lblNumOfActivePeople.frame.origin.y + 80, lblNumOfActivePeople.frame.size.width, lblNumOfActivePeople.frame.size.height);
        }

        
        // Note that the GADBannerView checks its frame size to determine what size
        // creative to request.
        //Initialize the banner off the screen so that it animates up when displaying
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
    [super viewWillAppear:animated];
    
    [adBanner loadRequest:[self createRequest]];
    
    NSArray *ious = [[DataService sharedDataService] getIOUs];
    NSMutableArray *people = [[NSMutableArray alloc] init];
    for(Person *p in [[DataService sharedDataService] getPeople]) {
        if([[p getOutstandingBalance] floatValue] != 0) {
            [people addObject:p];
        }
    }
    
    // *** SUMMARY VIEW *** //
        
    // calculate money lent and money borrowed
    NSDecimalNumber *moneyLent = [[NSDecimalNumber alloc] initWithFloat:0.0f];
    NSDecimalNumber *moneyBorrowed = [[NSDecimalNumber alloc] initWithFloat:0.0f];
    for(IOU *iou in ious) {
        for(IOUPersonLink *link in iou.peopleLink) {
            if([link.amountOwed floatValue] < 0.0) { // i borrowed money
                moneyBorrowed = [moneyBorrowed decimalNumberByAdding:link.amountOwed];
            } else { // i lent money
                moneyLent = [moneyLent decimalNumberByAdding:link.amountOwed];

            }
        }
    }
    
    NSNumberFormatter *numformatter = [[NSNumberFormatter alloc] init];
    [numformatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numformatter setNegativeFormat:@"-¤#,##0.00"];
    
    // MONEY SECTION

    lblMoneyLentAmount.text = [numformatter stringFromNumber:moneyLent];
    lblPaymentsReceivedAmount.text = [numformatter stringFromNumber:[[DataService sharedDataService] getTotalPaymentsReceived]];
    lblMoneyBorrowedAmount.text = [numformatter stringFromNumber:[moneyBorrowed decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithInt: -1]]];
    lblPaymentsMadeAmount.text = [numformatter stringFromNumber:[[DataService sharedDataService] getTotalPaymentsMade]];

    NSDecimalNumber *balance = [NSDecimalNumber decimalNumberWithDecimal:[moneyLent decimalValue]];
    balance = [balance decimalNumberByAdding:moneyBorrowed];
    balance = [balance decimalNumberBySubtracting:[[DataService sharedDataService] getTotalPaymentsReceived]];
    balance = [balance decimalNumberByAdding:[[DataService sharedDataService] getTotalPaymentsMade]];
    lblTotalBalanceAmount.text = [numformatter stringFromNumber:balance];
    
    // IOUS SECTION
    int activeIOUs = 0;
    for(IOU *iou in ious) {
        BOOL iouActive = NO;
        for(IOUPersonLink *pl in iou.peopleLink) {
            if([[pl getOutstandingBalance] floatValue] > 0) {
                iouActive = YES;
                break;
            }
        }
        if(iouActive == YES) {
            activeIOUs++;
        }
    }
    lblNumOfActiveIOUs.text = [NSString stringWithFormat:@"Number of active IOUs: %i", activeIOUs];
    lblNumOfAllIOUs.text = [NSString stringWithFormat:@"Total number of IOUs: %i", ious.count];
    
    // PEOPLE SECTION
    lblNumOfActivePeople.text = [NSString stringWithFormat:@"Number of people with outstanding balances: %i", people.count];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark - Button Handlers

-(void)createIOUTapped:(id)sender {
    
    EditIOUViewController *vc = [[EditIOUViewController alloc] initWithIOU:[[DataService sharedDataService] createNewIOUObject]];
    vc.navController = self.navigationController;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Cancel"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:vc animated:YES];
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
    [UIView animateWithDuration:1.0 animations:^ {
        adView.frame = CGRectMake(0.0,
                                  self.view.frame.size.height -
                                  adView.frame.size.height,
                                  adView.frame.size.width,
                                  adView.frame.size.height);
        if(IS_WIDESCREEN ) {
            imgViewDropShadow.frame = CGRectMake(0, 399, imgViewDropShadow.frame.size.width, 6);
        }
        else {
            imgViewDropShadow.frame = CGRectMake(0, 311, imgViewDropShadow.frame.size.width, 6);
        }
        
        adView.backgroundColor = [UIColor blackColor];
    }];
}

- (void)adView:(GADBannerView *)view
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}

@end