//
//  ViewIOUViewController.h
//  TrackMyCash
//
//  Created by Ray Tam on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewIOUViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    UINavigationController *navController;
    IOU *myIOU;
    UIBarButtonItem *doneButton;
    UIScrollView *scrollView;
    
    UILabel *lblTypeofIOU;
    UILabel *lblDescription;
    UILabel *lblDescriptionValue;
    UILabel *lblNotes;
    UILabel *lblNotesValue;
    UILabel *lblDate;
    UILabel *lblTotalBalance;
    UILabel *lblTotalBalanceValue;
    UILabel *lblBalanceLeft;
    
    UITableView *tblPeople;
}

@property (nonatomic, retain) UINavigationController *navController;

- (id)initWithIOU:(IOU*)iou;

@end
