//
//  AddPersonToIOUViewController.h
//  Track My Money
//
//  Created by Raymond Tam on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddPersonToIOUDelegate <NSObject>

-(void)didAddNewPerson:(NSString *)name withAmount:(NSDecimalNumber *)amount;

@end

@interface AddPersonToIOUViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
    id<AddPersonToIOUDelegate> delegate;
    UILabel *lblName;
    UILabel *lblAmount;
    UITextField *txtName;
    UITextField *txtAmount;
    UIBarButtonItem *btnDone;
    IOUPersonLink *existingIOUPersonLink;
    UIBarButtonItem *addPersonButton;
    UITableView *autocompleteTableView;
    NSMutableArray *autocompleteNames;
}

@property (nonatomic, retain) id<AddPersonToIOUDelegate> delegate;
@property (nonatomic, retain) IOUPersonLink *existingIOUPersonLink;


@end
