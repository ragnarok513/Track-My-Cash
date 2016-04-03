//
//  AddPersonToIOUViewController.m
//  Track My Money
//
//  Created by Raymond Tam on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AddPersonToIOUViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>

#define CELL_HEIGHT 30.0f

@implementation AddPersonToIOUViewController {
    NSMutableArray *listOfPeople;
}

@synthesize existingIOUPersonLink, delegate;


#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Add Person";
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 60, 31)];
        lblName.textAlignment = UITextAlignmentRight;
        lblName.text = @"Name";
        [lblName setFont:DEFAULT_FONT(DEFAULT_HEADER_SIZE)];
        lblName.backgroundColor = [UIColor clearColor];
        [self.view addSubview:lblName];
        
        txtName = [[UITextField alloc] initWithFrame:CGRectMake(90, 20, self.view.frame.size.width - 110, 31)];
        txtName.borderStyle = UITextBorderStyleRoundedRect;
        [txtName setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        txtName.placeholder = @"Enter name";
        txtName.clearButtonMode = UITextFieldViewModeWhileEditing;
        txtName.autocapitalizationType = UITextAutocapitalizationTypeWords;
        txtName.autocorrectionType = UITextAutocorrectionTypeNo;
        txtName.returnKeyType = UIReturnKeyDefault;
        txtName.delegate = self;
        [self.view addSubview:txtName];
        
        lblAmount = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, 100, 31)];
        lblAmount.text = @"Amount";
        [lblAmount setFont:DEFAULT_FONT(DEFAULT_HEADER_SIZE)];
        lblAmount.backgroundColor = [UIColor clearColor];
        [self.view addSubview:lblAmount];
        
        txtAmount = [[UITextField alloc] initWithFrame:CGRectMake(90, 160, 110, 31)];
        txtAmount.borderStyle = UITextBorderStyleRoundedRect;
        [txtAmount setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        txtAmount.text = @"$0";
        txtAmount.keyboardType = UIKeyboardTypeDecimalPad;
        txtAmount.delegate = self;
        txtAmount.textAlignment = UITextAlignmentRight;
        [self.view addSubview:txtAmount];
        
        autocompleteNames = [[NSMutableArray alloc] init];
        autocompleteTableView = [[UITableView alloc] initWithFrame: CGRectMake(90, 51, self.view.frame.size.width - 110, 108) style:UITableViewStyleGrouped];
        autocompleteTableView.backgroundColor = [UIColor clearColor];
        autocompleteTableView.backgroundView = nil;
        autocompleteTableView.rowHeight = CELL_HEIGHT;
        autocompleteTableView.delegate = self;
        autocompleteTableView.dataSource = self;
        [self.view addSubview:autocompleteTableView];
        
        // set up top right button
        addPersonButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];
        self.navigationItem.rightBarButtonItem = addPersonButton;
        
        //*** DROPSHADOW ***//
        UIImage *imgDropShadow = [UIImage imageNamed:@"dropshadow.png"];
        UIImageView *imgViewDropShadow = [[UIImageView alloc] initWithImage:imgDropShadow];
        imgViewDropShadow.frame = CGRectMake(0, 200 - imgDropShadow.size.height, imgDropShadow.size.width, imgDropShadow.size.height);
        [self.view addSubview:imgViewDropShadow];
        
        //*** WIDESCREEN COMPATIBILITY ***//
        if(IS_WIDESCREEN) {
            autocompleteTableView.frame = CGRectMake(autocompleteTableView.frame.origin.x, autocompleteTableView.frame.origin.y, autocompleteTableView.frame.size.width, autocompleteTableView.frame.size.height + WIDESCREEN_HEIGHT_DIFFERENCE);
            
            lblAmount.frame = CGRectMake(lblAmount.frame.origin.x, lblAmount.frame.origin.y + WIDESCREEN_HEIGHT_DIFFERENCE, lblAmount.frame.size.width, lblAmount.frame.size.height);
            txtAmount.frame = CGRectMake(txtAmount.frame.origin.x, txtAmount.frame.origin.y + WIDESCREEN_HEIGHT_DIFFERENCE, txtAmount.frame.size.width, txtAmount.frame.size.height);

            imgViewDropShadow.frame = CGRectMake(imgViewDropShadow.frame.origin.x, imgViewDropShadow.frame.origin.y + WIDESCREEN_HEIGHT_DIFFERENCE, imgViewDropShadow.frame.size.width, imgViewDropShadow.frame.size.height);

        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self populateNamesTable];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        ABAuthorizationStatus as = ABAddressBookGetAuthorizationStatus();
        ABAddressBookRef addressBook = nil;
        if(as == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                // callback can occur in background, address book must be accessed on thread it was created on
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error && granted) {
                        [self populateNamesTable];
                    }
                });
            });
        }
    }
    
    //prepopulate fields if we have a person index
    if(existingIOUPersonLink != nil) {
        txtAmount.text = [NSString stringWithFormat:@"$%@", [existingIOUPersonLink.amountOwed stringValue]];
        txtName.text = existingIOUPersonLink.person.name;
        
        // keyboard toolbar
        UIToolbar *keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 35)];
        btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
        [keyboardToolBar setBarStyle:UIBarStyleBlackTranslucent];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil];
        NSArray *buttonArray = [NSArray arrayWithObjects: flexibleSpace, btnDone, nil];
        [keyboardToolBar setItems: buttonArray];
        [txtAmount setInputAccessoryView:keyboardToolBar];
        
        //adjust controls so that only amount is editable
        [txtAmount becomeFirstResponder];
        txtName.backgroundColor = [UIColor grayColor];
        txtName.enabled = NO;
        autocompleteTableView.userInteractionEnabled = NO;
        addPersonButton.title = @"Save";
        
        float adjustment = 100;
        
        if(IS_WIDESCREEN) {
            adjustment = 190;
        }
        
        lblAmount.frame = CGRectMake(lblAmount.frame.origin.x, lblAmount.frame.origin.y - adjustment, lblAmount.frame.size.width, lblAmount.frame.size.height);
        txtAmount.frame = CGRectMake(txtAmount.frame.origin.x, txtAmount.frame.origin.y - adjustment, txtAmount.frame.size.width, txtAmount.frame.size.height);
        
        
    }
    else {
        addPersonButton.enabled = NO;
        [txtName becomeFirstResponder];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)doneButtonTapped:(id)sender
{
    NSString *newPersonName = txtName.text;
    NSMutableString *text;
    if(txtAmount.text.length == 0)
        text = [NSMutableString stringWithString:@"0"];
    else
        text = [NSMutableString stringWithString:txtAmount.text];
    
    // strip out invalid characters, everything but digits
    NSCharacterSet *charSet = [[NSCharacterSet characterSetWithCharactersInString:@".0123456789"] invertedSet];
    text = [NSMutableString stringWithString:[[text componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""]];
    
    // convert to nsdecimalnumber
    NSDecimalNumber *num = [NSDecimalNumber decimalNumberWithString:text];
    
    // if we're editing an existing person, then just go ahead and update with info
    if(existingIOUPersonLink != nil)
    {
        // if my previous amountpaid amount is larger than the new amount owed, then this is my amount paid
        if([existingIOUPersonLink.amountPaid floatValue] > [num floatValue]) {
            existingIOUPersonLink.amountPaid = num;
        }
        else {
            existingIOUPersonLink.paidOn = nil;
        }
        existingIOUPersonLink.amountOwed = num;
    }
    else
    {
        [delegate didAddNewPerson:newPersonName withAmount:num];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark -
#pragma mark UITableViewDelegate functions


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    return autocompleteNames.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdent = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdent];
    }
    
    cell.textLabel.text = [autocompleteNames objectAtIndex:indexPath.row];
    [cell.textLabel setFont:DEFAULT_FONT(16)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    txtName.text = selectedCell.textLabel.text;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self ensureAddButtonEnabled];
    
    // move onto amount field
    [txtAmount becomeFirstResponder];
    
    
}

#pragma mark - UITextFieldDelegate functions

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField == txtName) {
        // handle autocomplete table
        NSString *substring = [NSString stringWithString:textField.text];
        substring = [substring 
                     stringByReplacingCharactersInRange:range withString:string];
        [self searchAutocompleteEntriesWithSubstring:substring];
    }
    // only do formatting on the numpad and also allow backspace to go through
    else if(textField == txtAmount) {
        // read in current string textField.text
        NSCharacterSet *charSet = [[NSCharacterSet characterSetWithCharactersInString:@".0123456789"] invertedSet];
        NSMutableString *text = [[NSMutableString alloc] init];
        
        
        // if the string is a period, don't add another if there is already one there
        if([string isEqualToString:@"."]) {
            if([textField.text rangeOfString:@"."].location == NSNotFound) {
                if(textField.text.length == 1) {
                    // this means that there is only a dollar sign here, add a leading zero in front of the decimal
                    text = [NSString stringWithFormat:@"%@0%@", textField.text, string];
                }
                else {
                    text = [NSString stringWithFormat:@"%@%@", textField.text, string];
                }
            } else {
                text = [NSMutableString stringWithString:textField.text];
            }
        }
        else {
            NSString *strippedText = [NSMutableString stringWithString:[[textField.text componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""]];
            NSString *newNum = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@%@", strippedText, string]];
            
            NSRange decimalRange = [strippedText rangeOfString:@"."];
            if(decimalRange.location != NSNotFound && decimalRange.location == strippedText.length - 3) { // number was added, check if we have a decimal already and 2 digits after, if we do then don't add the number
                text = [NSMutableString stringWithString:textField.text];
            }
            else if ([strippedText floatValue] == 0 && ([string floatValue] == 0 && decimalRange.location == NSNotFound)) { // 0 was added and we don't have decimals in the string, don't tack on more zeros
                text = [NSMutableString stringWithString:textField.text];
            }
            else if ([newNum floatValue] > 999999.99) { // lets limit the iou amount
                text = [NSMutableString stringWithString:textField.text];
            }
            else if([strippedText floatValue] == 0) { // the number has no value so its currently "$0", just set the text to be the new number
                if([strippedText rangeOfString:@"."].location != NSNotFound) { // if there was a decimal in our text, retain that decimal
                    if([strippedText isEqualToString:@"0.0"] && ![string isEqualToString:@"0"]) { // user wants to add cent value that was not zero
                        text = [NSMutableString stringWithString:[NSString stringWithFormat:@"0.0%@", string]];
                    }
                    else {
                        text = [NSMutableString stringWithString:[NSString stringWithFormat:@"0.%@", string]];
                    }
                }
                else {
                    text = [NSMutableString stringWithString:string];
                }
            }
            else {
                text = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@%@", textField.text, string]];
            }
        }
        
        // strip out invalid characters, everything but digits and the period
        text = [NSMutableString stringWithString:[[text componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""]];
        
        // if string is empty string, then that means backspace was pressed, remove last digit of text
        if([string length] == 0 && text.length > 0) {
            [text setString:[text substringToIndex:text.length - 1]];
            
            // if my text is a zero at this point, remove the zero
            if(text.length == 0) {
                [text setString:@"0"];
            }
        }
        
        if(text.length > 3) // place commas if needed
        {
            int onesIndex;
            NSRange decimalRange = [text rangeOfString:@"."];
            if(decimalRange.location == NSNotFound) {
                onesIndex = text.length - 1;
            }
            else {
                onesIndex = decimalRange.location - 1;
            }
            
            if(onesIndex >= 3) { // insert comma, since we limit the user to under a mil then we don't need to check any further
                [text insertString:@"," atIndex:onesIndex - 2];
            }
        }
        
        // spit out string back to textbox
        textField.text = [NSString stringWithFormat:@"$%@", text];

        
        [self ensureAddButtonEnabled];
        return NO;
    }
    
    [self ensureAddButtonEnabled];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [txtAmount becomeFirstResponder];
    return NO;
}


-(void) searchAutocompleteEntriesWithSubstring:(NSString *)substring
{
    [autocompleteNames removeAllObjects];
    // Put anything that starts with this substring into the autocompleteUrls array
    // The items in this array is what will show up in the table view
    if(substring.length == 0) {
        autocompleteNames = [NSMutableArray arrayWithArray:listOfPeople];
    }
    else {
        for(NSString *name in listOfPeople) {
            NSRange substringRange = [[name lowercaseString] rangeOfString:[substring lowercaseString]];
            if (substringRange.length > 0 && ![autocompleteNames containsObject:name]) {
                [autocompleteNames addObject:name];  
            }
        }
    }
    [autocompleteTableView reloadData];
    autocompleteTableView.contentOffset = CGPointMake(0, 0);
}

#pragma mark - Helper Functions

-(void)populateNamesTable {
    listOfPeople = [[NSMutableArray alloc] init];
    
    // pull contacts from existing app contacts
    NSArray *appContacts = [[DataService sharedDataService] getPeople];
    for(Person *p in appContacts) {
        if(![listOfPeople containsObject:[p.name lowercaseString]]) {
            [listOfPeople addObject:p.name];
        }
        
    }
    
    // pull contacts from device
    NSMutableArray *listOfPeopleLowercased = [[NSMutableArray alloc] init];
    for(int i = 0; i < listOfPeople.count; i++) {
        [listOfPeopleLowercased addObject:[[listOfPeople objectAtIndex:i] lowercaseString]];
    }
    
    ABAddressBookRef addressBook = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            addressBook = ABAddressBookCreate();
        }
    }
    else {
        addressBook = ABAddressBookCreate();
    }
    
    if(addressBook != nil) {
        CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
        for(int i = 0; i < ABAddressBookGetPersonCount(addressBook); i++) {
            ABRecordRef ref = CFArrayGetValueAtIndex(people, i);
            NSString *fullName = (__bridge NSString *) ABRecordCopyCompositeName(ref);
            
            if(fullName != nil) {
                if(![listOfPeopleLowercased containsObject:[fullName lowercaseString]]) {
                    [listOfPeople addObject:fullName];
                }
            }
        }
    }
    
    [listOfPeople sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    if(existingIOUPersonLink == nil) {
        [self searchAutocompleteEntriesWithSubstring:txtName.text];
    }
}

-(void)ensureAddButtonEnabled {
    NSCharacterSet *charSet = [[NSCharacterSet characterSetWithCharactersInString:@".0123456789"] invertedSet];
    NSString *strippedText = [NSMutableString stringWithString:[[txtAmount.text componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""]];
    if(strippedText.length == 0) {
        strippedText = @"0";
    }
    
    if(txtName.text.length == 0 || [strippedText floatValue] <= 0) {
        addPersonButton.enabled = NO;
        btnDone.enabled = NO;
    }
    else {
        addPersonButton.enabled = YES;
        btnDone.enabled = YES;
    }
}

@end
