//
//  SummaryViewController.h
//  Track My Money
//
//  Created by Raymond Tam on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerViewDelegate.h"

@class GADBannerView, GADRequest;

@interface SummaryViewController : UIViewController <GADBannerViewDelegate> {
    GADBannerView *adBanner;
    UIImageView *imgViewDropShadow;
    
    UILabel *lblMoney;
    UILabel *lblMoneyLent;
    UILabel *lblMoneyLentAmount;
    UILabel *lblPaymentsReceived;
    UILabel *lblPaymentsReceivedAmount;
    UILabel *lblMoneyBorrowed;
    UILabel *lblMoneyBorrowedAmount;
    UILabel *lblPaymentsMade;
    UILabel *lblPaymentsMadeAmount;
    UIView *blackBar;
    UILabel *lblTotalBalance;
    UILabel *lblTotalBalanceAmount;
    UILabel *lblIOUs;
    UILabel *lblNumOfActiveIOUs;
    UILabel *lblNumOfAllIOUs;
    UILabel *lblPeople;
    UILabel *lblNumOfActivePeople;
}

@property(nonatomic, retain) GADBannerView *adBanner;

@property (nonatomic, retain) UILabel *lblMoneyLent;
@property (nonatomic, retain) UILabel *lblMoneyLentAmount;
@property (nonatomic, retain) UILabel *lblMoneyBorrowed;
@property (nonatomic, retain) UILabel *lblMoneyBorrowedAmount;
@property (nonatomic, retain) UILabel *lblTotalBalance;
@property (nonatomic, retain) UILabel *lblTotalBalanceAmount;
@property (nonatomic, retain) UILabel *lblNumOfActiveIOUs;
@property (nonatomic, retain) UILabel *lblNumOfAllIOUs;
@property (nonatomic, retain) UILabel *lblNumOfActivePeople;
@property (nonatomic, retain) UILabel *lblMoney;
@property (nonatomic, retain) UILabel *lblIOUs;
@property (nonatomic, retain) UILabel *lblPeople;

- (GADRequest *)createRequest;

@end
