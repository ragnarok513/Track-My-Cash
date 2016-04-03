//
//  EditIOUViewController.m
//  Track My Money
//
//  Created by Raymond Tam on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EditIOUViewController.h"
#import "AddPersonToIOUViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation EditIOUViewController {
    
}

@synthesize navController;

#pragma mark - View Lifecycle

- (id)initWithIOU:(IOU*)iou
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        myIOU = iou;
        
        // set background
        [self.view setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
        
        tblIOUData = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - TABBARHEIGHT) style:UITableViewStyleGrouped];
        tblIOUData.dataSource = self;
        tblIOUData.delegate = self;
        tblIOUData.editing = YES;
        tblIOUData.allowsSelectionDuringEditing = YES;
        tblIOUData.backgroundColor = [UIColor clearColor];
        tblIOUData.backgroundView = nil;
        [self.view addSubview:tblIOUData];
        
        // set up top bar buttons
        doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];  
        self.navigationItem.rightBarButtonItem = doneButton;
        [self ensureDoneButtonEnabled];
        
        int validPeople = 0;
        for(IOUPersonLink *pl in myIOU.peopleLink) {
            if(!pl.isDeleted)
                validPeople++;
        }
        if((validPeople == 0) || [((IOUPersonLink*)[[myIOU.peopleLink allObjects] objectAtIndex:0]).amountOwed floatValue] >= 0) {
            iLoanedOutMoney = YES;
        }
        else {
            iLoanedOutMoney = NO;
        }
        
        if(!myIOU.hasChanges) { // we're editing an existing IOU
            [doneButton setTitle:@"Save"];
            self.title = myIOU.title;
        }
        else {
            myIOU.notes = @"";
            myIOU.date = [NSDate date];
            self.title = @"Create IOU";
        }
        
        //*** DROPSHADOW ***//
        UIImage *imgDropShadow = [UIImage imageNamed:@"dropshadow.png"];
        UIImageView *imgViewDropShadow = [[UIImageView alloc] initWithImage:imgDropShadow];
        imgViewDropShadow.frame = CGRectMake(0, self.view.frame.size.height - TABBARHEIGHT - imgDropShadow.size.height, imgDropShadow.size.width, imgDropShadow.size.height);
        [self.view addSubview:imgViewDropShadow];
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.  
        [[DataService sharedDataService] rollback];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [tblIOUData reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone]; // when the user changes the amount on an existing person, we need to refresh their amount here
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section) {
        case 0:
            return 4;
            break;
        case 1:
        {
            int validPeople = 0;
            for(IOUPersonLink *pl in myIOU.peopleLink) {
                if(!pl.isDeleted)
                    validPeople++;
            }
            return validPeople + 1;
            break;
        }
        default:
            return 0;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch(section) {
        case 0:
            return @"IOU Details";
            break;
        case 1:
        {
            NSDecimalNumber *total = [[NSDecimalNumber alloc] initWithInt:0];
            for(IOUPersonLink *pl in myIOU.peopleLink) {
                if(!pl.isDeleted)
                    total = [total decimalNumberByAdding:pl.amountOwed];
            }
            
            NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
            [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            
            return [NSString stringWithFormat:@"People (Total %@)", [currencyFormatter stringFromNumber:total]];
            break;
        }
        default:
            return @"";
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell;
    
    
    switch (indexPath.section) {
        case 0:
            {
                switch (indexPath.row) {
                    case 0:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                        cell.textLabel.text = @"Type of IOU";
                        if(iLoanedOutMoney) {
                            cell.detailTextLabel.text = @"I loaned out money";
                        }
                        else {
                            cell.detailTextLabel.text = @"I borrowed money";
                        }
                        break;
                    case 1:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                        cell.textLabel.text = @"For";
                        cell.detailTextLabel.text = myIOU.title;
                        break;
                    case 2:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                        cell.textLabel.text = @"Notes";
                        cell.detailTextLabel.text = myIOU.notes;
                        break;
                    case 3:
                    {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                        cell.textLabel.text = @"Date";
                        
                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                        [dateFormat setDateFormat:@"M/dd/YYYY"];
                        cell.detailTextLabel.text = [dateFormat stringFromDate:myIOU.date];
                        break;
                    }
                    default:
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                        cell.textLabel.text = @"";
                        break;
                }
            }
            [cell.detailTextLabel setFont:DEFAULT_FONT_LIGHT(16)];
            break;
        case 1:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                
                int validPeople = 0;
                for(IOUPersonLink *pl in myIOU.peopleLink) {
                    if(!pl.isDeleted)
                        validPeople++;
                }
                
                if(indexPath.row == 0) {
                    cell.textLabel.text = @"Add person";
                    cell.detailTextLabel.text = @"";
                }
                else {
                    
                    NSMutableArray *validPeople = [NSMutableArray arrayWithArray:[[myIOU.peopleLink allObjects] sortedArrayUsingSelector:@selector(compare:)]];
                    for(int i = validPeople.count - 1; i >= 0; i--) {
                        if(((IOUPersonLink *)[validPeople objectAtIndex:i]).isDeleted) {
                            [validPeople removeObjectAtIndex:i];
                        }
                    }
                    
                    IOUPersonLink *pl = [validPeople objectAtIndex:indexPath.row - 1];
                    
                    NSString *fullName = pl.person.name;
                    if([pl.amountOwed compare:[NSDecimalNumber zero]] == NSOrderedAscending) { // need to make any numbers positive because it will be converted again when we save
                        pl.amountOwed = [pl.amountOwed decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithInt:-1]];
                    }
                    NSDecimalNumber *amountOwed = pl.amountOwed;
                    
                    
                    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
                    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                    NSString *stringAmount = [currencyFormatter stringFromNumber:amountOwed];
                    
                    cell.textLabel.text = fullName;
                    cell.detailTextLabel.text = stringAmount;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                [cell.detailTextLabel setFont:DEFAULT_FONT_LIGHT(14)];
                break;
            }
        default:
            break;
    }
    
    [cell.textLabel setFont:DEFAULT_FONT(16)];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    // type of iou
                    UIActionSheet *sheet = [[UIActionSheet alloc] 
                                            initWithTitle:@"Type of IOU"
                                            delegate:self
                                            cancelButtonTitle:nil
                                            destructiveButtonTitle:nil
                                            otherButtonTitles:@"I loaned out money", @"I borrowed money", nil];
                    
                    [sheet showInView:self.parentViewController.tabBarController.view];
                    break;
                }
                case 1:
                {
                    // description
                    alrtDescription = [[UIAlertView alloc] initWithTitle:@"For" message:nil delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
                    alrtDescription.alertViewStyle = UIAlertViewStylePlainTextInput;
                    alrtDescription.delegate = self;
                    [alrtDescription textFieldAtIndex:0].delegate = self;
                    [alrtDescription textFieldAtIndex:0].text = myIOU.title;
                    [alrtDescription textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
                    [alrtDescription show];
                    break;
                }
                case 2:
                {
                    // notes
                    alrtNotes = [[UIAlertView alloc] initWithTitle:@"Notes" message:nil delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
                    alrtNotes.alertViewStyle = UIAlertViewStylePlainTextInput;
                    alrtNotes.delegate = self;
                    [alrtNotes textFieldAtIndex:0].delegate = self;
                    [alrtNotes textFieldAtIndex:0].text = myIOU.notes;
                    [alrtNotes textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
                    [alrtNotes show];
                    break;
                }
                case 3:
                {
                    // date of transaction
                    actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                              delegate:nil
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:nil];
                    
                    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
                    
                    
                    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, 0, 0)];
                    datePicker.datePickerMode = UIDatePickerModeDate;
                    datePicker.date = myIOU.date;
                    [actionSheet addSubview:datePicker];
                    
                    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [btnDone setBackgroundImage:[[UIImage imageNamed:@"btn-blue-border.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0] forState:UIControlStateNormal];
                    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
                    [btnDone.titleLabel setFont:[UIFont boldSystemFontOfSize:(14)]];
                    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    btnDone.frame = CGRectMake(255, 8, 55, 24);
                    [btnDone addTarget:self action:@selector(changedDate:) forControlEvents:UIControlEventTouchUpInside];
                    [actionSheet addSubview:btnDone];

                    
                    [actionSheet showInView:self.parentViewController.tabBarController.view];
                    
                    [actionSheet setBounds:CGRectMake(0, 0, 320, 485)];

                    
                    break;
                }
                default:
                    break;
            }
            break;
        case 1:
        {
            // set backbutton text for next view
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                           initWithTitle: @"Cancel" 
                                           style: UIBarButtonItemStyleBordered
                                           target: nil action: nil];
            
            [self.navigationItem setBackBarButtonItem:backButton];
            
            AddPersonToIOUViewController *vc = [[AddPersonToIOUViewController alloc] init];
            vc.delegate = self;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            // if this isn't the last row, then we're editing not adding
            NSMutableArray *validPeople = [NSMutableArray arrayWithArray:[[myIOU.peopleLink allObjects] sortedArrayUsingSelector:@selector(compare:)]];
            for(int i = validPeople.count - 1; i >= 0; i--) {
                if(((IOUPersonLink *)[validPeople objectAtIndex:i]).isDeleted) {
                    [validPeople removeObjectAtIndex:i];
                }
            }
            
            if(indexPath.row != 0) {
                vc.existingIOUPersonLink = (IOUPersonLink *)[validPeople objectAtIndex:indexPath.row - 1];
            }
            else {
                vc.existingIOUPersonLink = nil;
            }
            
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:
(NSIndexPath *)indexPath
{
    if(indexPath.section == 1) {
        int validPeople = 0;
        for(IOUPersonLink *pl in myIOU.peopleLink) {
            if(!pl.isDeleted)
                validPeople++;
        }
        
        if(indexPath.row == 0) {
            return UITableViewCellEditingStyleInsert;
        }
        else {
            return UITableViewCellEditingStyleDelete;
        }
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1) {
        // If row is deleted, remove it from the list.
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            NSMutableArray *validPeople = [NSMutableArray arrayWithArray:[[myIOU.peopleLink allObjects] sortedArrayUsingSelector:@selector(compare:)]];
            for(int i = validPeople.count - 1; i >= 0; i--) {
                if(((IOUPersonLink *)[validPeople objectAtIndex:i]).isDeleted) {
                    [validPeople removeObjectAtIndex:i];
                }
            }
            
            if(validPeople.count == 1) {
                // show alert, can't delete the only person
                UIAlertView *alrtDeletePersonError = [[UIAlertView alloc] initWithTitle:nil message:@"Unable to delete this person, IOUs must have associated with at least one person" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
                [alrtDeletePersonError show];
            }
            else {
                [[DataService sharedDataService] deleteObject:[validPeople objectAtIndex:indexPath.row]];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
        else if(editingStyle == UITableViewCellEditingStyleInsert)
        {
            // set backbutton text for next view
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                           initWithTitle: @"Cancel" 
                                           style: UIBarButtonItemStyleBordered
                                           target: nil action: nil];
            
            [self.navigationItem setBackBarButtonItem: backButton];
            
            AddPersonToIOUViewController *vc = [[AddPersonToIOUViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - Button Handlers

-(void)changedDate:(id)sender {
    myIOU.date = datePicker.date;
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    [tblIOUData reloadData];
}

-(void)doneButtonTapped:(id)sender {
    // need to make adjustments to amounts based off iou type
    for(IOUPersonLink *pl in myIOU.peopleLink) {
        if(!pl.isDeleted) {
            if(iLoanedOutMoney == 0 && pl.amountOwed > 0) {
                pl.amountOwed = [pl.amountOwed decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithInt:-1]];
            }
            else if(iLoanedOutMoney == 1 && pl.amountOwed < 0) {
                pl.amountOwed = [pl.amountOwed decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithInt:-1]];
            }
        }
    }
    
    [[DataService sharedDataService] saveChanges];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextFieldDelegate functions

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [alrtNotes dismissWithClickedButtonIndex:0 animated:YES];
    [alrtDescription dismissWithClickedButtonIndex:0 animated:YES];
    return YES;
}

#pragma mark AddPersonToIOU Delegate Functions

-(void)didAddNewPerson:(NSString *)name withAmount:(NSDecimalNumber *)amount {
    // before we go and add a new row, check to see if there is already a row for this person
    for(IOUPersonLink *pl in [myIOU.peopleLink allObjects]) {
        if([[pl.person.name lowercaseString] isEqualToString:[name lowercaseString]] && !pl.isDeleted) {
            pl.amountOwed = [pl.amountOwed decimalNumberByAdding:amount];
            return;
        }
    }
    
    // add new row
    IOUPersonLink *pl = [[DataService sharedDataService] createNewIOUPersonLinkObject];
    
    // find out if this person already exists in the db, if so then use that person object, otherwise create a new one
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    NSArray *people = [[DataService sharedDataService] executeFetchRequestOnEntity:@"Person" predicate:predicate];
    Person *p;
    if(people.count > 0) { // existing person found
        p = [people objectAtIndex:0];
    }
    else {
        p = [[DataService sharedDataService] createNewPersonObject];
        p.name = name;
    }
    
    pl.amountOwed = amount;
    pl.person = p;
    pl.iou = myIOU;
    
    [tblIOUData reloadData];
    [self ensureDoneButtonEnabled];
}

#pragma mark - UIActionSheetDelegate functions

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        iLoanedOutMoney = YES;
    }
    else {
        iLoanedOutMoney = NO;
    }
    [tblIOUData reloadData];
}

#pragma mark - UIAlertViewDelegate functions

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView == alrtDescription) {
        myIOU.title = [alertView textFieldAtIndex:0].text;
        
        [self ensureDoneButtonEnabled];
    }
    else if(alertView == alrtNotes) {
        myIOU.notes = [alertView textFieldAtIndex:0].text;
    }
    [tblIOUData reloadData];
}

#pragma mark - helper functions
-(void)ensureDoneButtonEnabled {
    int validPeople = 0;
    for(IOUPersonLink *pl in myIOU.peopleLink) {
        if(!pl.isDeleted)
            validPeople++;
    }
    
    if(validPeople > 0 && myIOU.title.length > 0)
        doneButton.enabled = YES;
    else
        doneButton.enabled = NO;
}

@end
