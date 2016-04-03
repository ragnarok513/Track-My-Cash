//
//  PaymentViewController.m
//  Track My Money
//
//  Created by Raymond Tam on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PaymentViewController.h"
#import "UICustomSwitch.h"

@implementation PaymentViewController {

}

@synthesize navController;

#pragma mark View lifecycle

- (id)initWithIOU:(IOU*)iou IOUPersonLink:(IOUPersonLink *)pl lockPl:(BOOL)lockPl
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = @"Make Payment";
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
        
        myIOU = iou;
        myPl = pl;
        myLockPl = lockPl;
        
        UILabel *lblTitle = [[UILabel alloc] init];
        if([((IOUPersonLink *)[[myIOU.peopleLink allObjects] objectAtIndex:0]).amountOwed floatValue] < 0) {
            lblTitle.text = @"I'm making payment to:";
        }
        else {
            lblTitle.text = @"I'm receiving payment from:";
        }
        
        lblTitle.frame = CGRectMake(20, 10, self.view.frame.size.width - 40, 30);
        lblTitle.backgroundColor = [UIColor clearColor];
        [lblTitle setFont:DEFAULT_FONT(DEFAULT_HEADER_SIZE)];
        [self.view addSubview:lblTitle];
        
        UILabel *lblName = [[UILabel alloc] init];
        lblName.frame = CGRectMake(20, 30, self.view.frame.size.width - 40, 30);
        [lblName setFont:DEFAULT_FONT_BOLD(DEFAULT_HEADER_SIZE + 2)];
        lblName.backgroundColor = [UIColor clearColor];
        lblName.minimumFontSize = 16.0f;
        lblName.adjustsFontSizeToFitWidth = YES;
        lblName.text = myPl.person.name;
        [self.view addSubview:lblName];
        
        NSNumberFormatter *numformatter = [[NSNumberFormatter alloc] init];
        [numformatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        UILabel *lblAmountOwed = [[UILabel alloc] init];
        lblAmountOwed.frame = CGRectMake(20, 55, self.view.frame.size.width - 40, 30);
        [lblAmountOwed setFont:DEFAULT_FONT(DEFAULT_HEADER_SIZE)];
        lblAmountOwed.backgroundColor = [UIColor clearColor];
        NSDecimalNumber *outstandingBalance = [myPl getOutstandingBalance];
        if([outstandingBalance floatValue] < 0) {
            outstandingBalance = [outstandingBalance decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithInt:-1]];
        }
        lblAmountOwed.text = [NSString stringWithFormat:@"Amount Owed: %@", [numformatter stringFromNumber:outstandingBalance]];
        [self.view addSubview:lblAmountOwed];
        
        UILabel *lblPayment = [[UILabel alloc] init];
        lblPayment.frame = CGRectMake(20, 90, 150, 30);
        [lblPayment setFont:DEFAULT_FONT(DEFAULT_HEADER_SIZE)];
        lblPayment.backgroundColor = [UIColor clearColor];
        lblPayment.text = @"Payment Amount:";
        [self.view addSubview:lblPayment];
        
        txtPayment = [[UITextField alloc] init];
        txtPayment.frame = CGRectMake(lblPayment.frame.size.width + 10, 90, 110, 30);
        txtPayment.borderStyle = UITextBorderStyleRoundedRect;
        [txtPayment setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        txtPayment.keyboardType = UIKeyboardTypeDecimalPad;
        txtPayment.delegate = self;
        txtPayment.textAlignment = UITextAlignmentRight;
        [self.view addSubview:txtPayment];
        
        UIButton *btnReversePaymentInfo = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnReversePaymentInfo setImage:[UIImage imageNamed:@"basic2-088-off.png"] forState:UIControlStateNormal];
        [btnReversePaymentInfo setImage:[UIImage imageNamed:@"basic2-088-on.png"] forState:UIControlStateHighlighted];
        btnReversePaymentInfo.frame = CGRectMake(-4, 113, 64, 64);
        [btnReversePaymentInfo addTarget:self action:@selector(reversePaymentInfoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnReversePaymentInfo];
        
        UILabel *lblReversePayment = [[UILabel alloc] init];
        lblReversePayment.frame = CGRectMake(btnReversePaymentInfo.frame.origin.x + btnReversePaymentInfo.frame.size.width - 15, 130, 140, 30);
        [lblReversePayment setFont:DEFAULT_FONT(DEFAULT_HEADER_SIZE)];
        lblReversePayment.backgroundColor = [UIColor clearColor];
        lblReversePayment.text = @"Reverse Payment?";
        [self.view addSubview:lblReversePayment];
        
        swReversePayment = [[UICustomSwitch alloc] initWithFrame:CGRectMake(lblReversePayment.frame.origin.x + lblReversePayment.frame.size.width + 5, 130, 50, 50)];
        swReversePayment.leftLabel.text = @"YES";
        swReversePayment.rightLabel.text = @"NO";
        [self.view addSubview:swReversePayment];
        
        [txtPayment becomeFirstResponder];
        
        lblPaidInFullOn = [[UILabel alloc] init];
        lblPaidInFullOn.frame = CGRectMake(20, 165, self.view.frame.size.width - 40, 30);
        [lblPaidInFullOn setFont:DEFAULT_FONT(DEFAULT_HEADER_SIZE)];
        lblPaidInFullOn.backgroundColor = [UIColor clearColor];
        [self.view addSubview:lblPaidInFullOn];
        
        if(myPl != nil) {
            [self setIOUPersonLink:myPl];
        }
        
        // set up top right button
        btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];
        self.navigationItem.rightBarButtonItem = btnSave;
        
        //*** DROPSHADOW ***//
        UIImage *imgDropShadow = [UIImage imageNamed:@"dropshadow.png"];
        UIImageView *imgViewDropShadow = [[UIImageView alloc] initWithImage:imgDropShadow];
        imgViewDropShadow.frame = CGRectMake(0, 200 - imgDropShadow.size.height, imgDropShadow.size.width, imgDropShadow.size.height);
        [self.view addSubview:imgViewDropShadow];
        
        //*** WIDESCREEN COMPATIBILITY ***//
        if(IS_WIDESCREEN) {
            lblAmountOwed.frame = CGRectMake(lblAmountOwed.frame.origin.x, lblAmountOwed.frame.origin.y + 5, lblAmountOwed.frame.size.width, lblAmountOwed.frame.size.height);
            
            lblPayment.frame = CGRectMake(lblPayment.frame.origin.x, lblPayment.frame.origin.y + 10, lblPayment.frame.size.width, lblPayment.frame.size.height);
            txtPayment.frame = CGRectMake(txtPayment.frame.origin.x, txtPayment.frame.origin.y + 10, txtPayment.frame.size.width, txtPayment.frame.size.height);
            
            [btnReversePaymentInfo removeFromSuperview];
            lblReversePayment.frame = CGRectMake(20, lblReversePayment.frame.origin.y + 15, lblReversePayment.frame.size.width, lblReversePayment.frame.size.height);
            swReversePayment.frame = CGRectMake(lblReversePayment.frame.origin.x + lblReversePayment.frame.size.width + 5, swReversePayment.frame.origin.y + 15, swReversePayment.frame.size.width, swReversePayment.frame.size.height);
            UILabel *lblReversePaymentInfo = [[UILabel alloc] initWithFrame:CGRectMake(20, lblReversePayment.frame.origin.y + 23, self.view.frame.size.width - 40, 50)];
            lblReversePaymentInfo.text = @"Turn this on to add payment back to amount owed.";
            lblReversePaymentInfo.numberOfLines = 2;
            [lblReversePaymentInfo setFont:DEFAULT_FONT(13)];
            lblReversePaymentInfo.backgroundColor = [UIColor clearColor];
            [self.view addSubview:lblReversePaymentInfo];
            
            
            
            
            lblPaidInFullOn.frame = CGRectMake(lblPaidInFullOn.frame.origin.x, lblPaidInFullOn.frame.origin.y + 60, lblPaidInFullOn.frame.size.width, lblPaidInFullOn.frame.size.height);
            
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
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.  
        [[DataService sharedDataService] rollback];
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

#pragma mark - Button Handlers

-(void)reversePaymentInfoButtonTapped:(id)sender {
    UIAlertView *alrtReversePayment = [[UIAlertView alloc] initWithTitle:@"" message:@"Turn this on to add payment back to amount owed." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alrtReversePayment show];
}

-(void)doneButtonTapped:(id)sender {
    NSCharacterSet *charSet = [[NSCharacterSet characterSetWithCharactersInString:@".0123456789"] invertedSet];
    NSString *strippedText = [NSMutableString stringWithString:[[txtPayment.text componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""]];
    if(strippedText.length == 0) {
        strippedText = @"0";
    }
    
    if(swReversePayment.on) {
        myPl.amountPaid = [myPl.amountPaid decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:strippedText]];
        if([myPl.amountPaid floatValue] < 0) {
            myPl.amountPaid = [NSDecimalNumber zero];
        }
        
    }
    else {
        myPl.amountPaid = [myPl.amountPaid decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:strippedText]];
        if([myPl.amountPaid floatValue] > [[myPl getAbsAmountOwed] floatValue]) {
            myPl.amountPaid = [myPl getAbsAmountOwed];
        }
    }
    
    if([[myPl getAbsAmountOwed] floatValue] == [myPl.amountPaid floatValue]) { // if the amount in textbox is equal to the amount owed, then we should update the paidOn date
        if(myPl.hasChanges) { // only update the paid off date if this was not already paid off
            myPl.paidOn = [NSDate date];
        }
    }
    else {
        myPl.paidOn = nil;
    }
    
    [[DataService sharedDataService] saveChanges];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate functions

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
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
    
    return NO;
}

#pragma mark - UIPickerView delegate functions

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return myIOU.peopleLink.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *str;

    IOUPersonLink *pl = [[[myIOU.peopleLink allObjects] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:row];
    str = pl.person.name;
    
    return str;
}

#pragma mark - Helper Functions

-(void)setIOUPersonLink:(IOUPersonLink *)pl {
    myPl = pl;
    
    // set payment amount to 0
    txtPayment.text = @"$0";
    
    if([myPl.amountPaid floatValue] == [[myPl getAbsAmountOwed] floatValue]) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"M/dd/YYYY"];
        lblPaidInFullOn.text = [NSString stringWithFormat:@"Paid in full on: %@", [dateFormat stringFromDate:pl.paidOn]];
    }
    else {
        lblPaidInFullOn.text = @"";
    }
}

@end
