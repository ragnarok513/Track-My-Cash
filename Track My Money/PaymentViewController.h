//
//  PaymentViewController.h
//  Track My Money
//
//  Created by Raymond Tam on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICustomSwitch.h"

@interface PaymentViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource> {
    UINavigationController *navController;
    IOU *myIOU;
    IOUPersonLink *myPl;
    BOOL myLockPl;
    
    
    UITableView *tblPerson;
    UIBarButtonItem *btnSave;
    UITextField *txtPayment;
    UICustomSwitch *swReversePayment;
    UILabel *lblPaidInFullOn;
    
    UIPickerView *pvPeople;
    UIActionSheet *asPeople;
}

@property (nonatomic, retain) UINavigationController *navController;

- (id)initWithIOU:(IOU*)iou IOUPersonLink:(IOUPersonLink *)pl lockPl:(BOOL)lockPl;

@end
