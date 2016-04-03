//
//  EditIOUViewController.h
//  Track My Money
//
//  Created by Raymond Tam on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddPersonToIOUViewController.h"

@interface EditIOUViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, AddPersonToIOUDelegate, UITextFieldDelegate> {
    
    UITableView *tblIOUData;
    UINavigationController *navController;
    UIBarButtonItem *doneButton;
    IOU *myIOU;
    UIAlertView *alrtDescription;
    UIAlertView *alrtNotes;
    UIDatePicker *datePicker;
    UIActionSheet *actionSheet;
    BOOL iLoanedOutMoney;
}

@property (nonatomic, retain) UINavigationController *navController;

- (id)initWithIOU:(IOU*)iou;

@end
