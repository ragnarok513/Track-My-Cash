//
//  PersonDetailsViewController.h
//  TrackMyCash
//
//  Created by Ray Tam on 8/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"

@interface PersonDetailsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FilterViewDelegate> {
    UINavigationController *navController;
    Person *myPerson;
    
    UILabel *lblTotalBalance;
    UILabel *lblTotalBalanceValue;
    UITableView *tblIOUs;
    FilterView *filterView;
}

@property (nonatomic, retain) UINavigationController *navController;

- (id)initWithPerson:(Person*)person;

@end
