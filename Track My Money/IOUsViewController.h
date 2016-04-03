//
//  IOUsViewController.h
//  Track My Money
//
//  Created by Raymond Tam on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerViewDelegate.h"
#import "FilterView.h"

@class GADBannerView, GADRequest;

@interface IOUsViewController : UIViewController <GADBannerViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, FilterViewDelegate> {
    GADBannerView *adBanner;
    UITableView *tblIOUs;
    UIImageView *imgViewDropShadow;
    FilterView *filterView;
}

- (void)loadAddIOUScreen;
- (GADRequest *)createRequest;

@end
