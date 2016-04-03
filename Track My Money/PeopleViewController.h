//
//  PeopleViewController.h
//  Track My Money
//
//  Created by Raymond Tam on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GADBannerViewDelegate.h"
#import "FilterView.h"

@class GADBannerView, GADRequest;

@interface PeopleViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, GADBannerViewDelegate, FilterViewDelegate> {
    GADBannerView *adBanner;
    UIImageView *imgViewDropShadow;
    FilterView *filterView;
}

@property(nonatomic, retain) GADBannerView *adBanner;

- (GADRequest *)createRequest;

@end
