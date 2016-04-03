//
//  ViewIOUViewController.m
//  TrackMyCash
//
//  Created by Ray Tam on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewIOUViewController.h"
#import "EditIOUViewController.h"
#import "CustomIOUCell.h"
#import "PaymentViewController.h"

#define CELL_HEIGHT 45.0f

@interface ViewIOUViewController ()

@end

@implementation ViewIOUViewController

@synthesize navController;


#pragma mark - Page Lifecycle

- (id)initWithIOU:(IOU*)iou
{
    self = [super init];
    if (self) {
        // Custom initialization
        myIOU = iou;
        self.title = myIOU.title;
        
        // set background
        [self.view setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - TABBARHEIGHT)];
        scrollView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:scrollView];
        
        // set up top bar buttons
        doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonTapped:)];  
        self.navigationItem.rightBarButtonItem = doneButton;
        
        lblTypeofIOU = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 30)];
        lblTypeofIOU.backgroundColor = [UIColor clearColor];
        [lblTypeofIOU setFont:DEFAULT_FONT_BOLD(20)];
        [scrollView addSubview:lblTypeofIOU];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 35, self.view.frame.size.width - 20, 1)];
        line.backgroundColor = [UIColor blackColor];
        [scrollView addSubview:line];
        
        lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 40, 30)];
        lblDescription.backgroundColor = [UIColor clearColor];
        [lblDescription setFont:DEFAULT_FONT(18)];
        [scrollView addSubview:lblDescription];
        
        lblDescriptionValue = [[UILabel alloc] initWithFrame:CGRectMake(lblDescription.frame.origin.x + lblDescription.frame.size.width, 40, self.view.frame.size.width - lblDescription.frame.size.width - 40, 30)];
        lblDescriptionValue.adjustsFontSizeToFitWidth = YES;
        lblDescriptionValue.minimumFontSize = 14;
        lblDescriptionValue.backgroundColor = [UIColor clearColor];
        [lblDescriptionValue setFont:DEFAULT_FONT(18)];
        [scrollView addSubview:lblDescriptionValue];
        
        lblDate = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, self.view.frame.size.width - 20, 30)];
        lblDate.backgroundColor = [UIColor clearColor];
        [lblDate setFont:DEFAULT_FONT(18)];
        [scrollView addSubview:lblDate];
        
        lblNotes = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 60, 30)];
        lblNotes.backgroundColor = [UIColor clearColor];
        [lblNotes setFont:DEFAULT_FONT(18)];
        [scrollView addSubview:lblNotes];
        
        lblNotesValue = [[UILabel alloc] initWithFrame:CGRectMake(lblNotes.frame.origin.x + lblNotes.frame.size.width, 100, self.view.frame.size.width - lblNotes.frame.size.width - 40, 30)];
        lblNotesValue.adjustsFontSizeToFitWidth = YES;
        lblNotesValue.minimumFontSize = 14;
        lblNotesValue.backgroundColor = [UIColor clearColor];
        [lblNotesValue setFont:DEFAULT_FONT(18)];
        [scrollView addSubview:lblNotesValue];
        
        lblTotalBalance = [[UILabel alloc] initWithFrame:CGRectMake(10, 130, self.view.frame.size.width - 20, 30)];
        lblTotalBalance.backgroundColor = [UIColor clearColor];
        [lblTotalBalance setFont:DEFAULT_FONT(18)];
        lblTotalBalance.text = @"Total Balance:";
        [lblTotalBalance sizeToFit];
        [scrollView addSubview:lblTotalBalance];
        
        lblTotalBalanceValue = [[UILabel alloc] initWithFrame:CGRectMake(lblTotalBalance.frame.origin.x + lblTotalBalance.frame.size.width + 5, 128, self.view.frame.size.width - lblTotalBalance.frame.size.width - 20, 30)];
        lblTotalBalanceValue.adjustsFontSizeToFitWidth = YES;
        lblTotalBalanceValue.backgroundColor = [UIColor clearColor];
        [lblTotalBalanceValue setFont:DEFAULT_FONT(18)];
        [scrollView addSubview:lblTotalBalanceValue];
        
        UILabel *lblPeople = [[UILabel alloc] initWithFrame:CGRectMake(10, 170, self.view.frame.size.width - 20, 30)];
        lblPeople.backgroundColor = [UIColor clearColor];
        [lblPeople setFont:DEFAULT_FONT_BOLD(20)];
        lblPeople.text = @"People";
        [scrollView addSubview:lblPeople];
        
        lblBalanceLeft = [[UILabel alloc] initWithFrame:CGRectMake(90, 170, self.view.frame.size.width - 20, 30)];
        lblBalanceLeft.backgroundColor = [UIColor clearColor];
        [lblBalanceLeft setFont:DEFAULT_FONT(16)];
        [scrollView addSubview:lblBalanceLeft];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(10, 195, self.view.frame.size.width - 20, 1)];
        line2.backgroundColor = [UIColor blackColor];
        [scrollView addSubview:line2];
        
        
        
        UILabel *lblInstructions = [[UILabel alloc] initWithFrame:CGRectMake(10, 195, self.view.frame.size.width - 20, 30)];
        lblInstructions.text = @"Select person to settle debt";
        lblInstructions.backgroundColor = [UIColor clearColor];
        [lblInstructions setFont:DEFAULT_FONT_LIGHT(16)];
        [scrollView addSubview:lblInstructions];
        
        //*** DROPSHADOW ***//
        UIImage *imgDropShadow = [UIImage imageNamed:@"dropshadow.png"];
        UIImageView *imgViewDropShadow = [[UIImageView alloc] initWithImage:imgDropShadow];
        imgViewDropShadow.frame = CGRectMake(0, self.view.frame.size.height - TABBARHEIGHT - imgDropShadow.size.height, imgDropShadow.size.width, imgDropShadow.size.height);
        [self.view addSubview:imgViewDropShadow];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    for (IOUPersonLink *pl in myIOU.peopleLink) {
        if([pl.amountOwed floatValue] >= 0) {
            lblTypeofIOU.text = @"I loaned out money";
        }
        else {
            lblTypeofIOU.text = @"I borrowed money";
        }
        break;
    }
    
    lblDescription.text = @"For:";
    lblDescriptionValue.text = myIOU.title;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"M/dd/YYYY"];
    lblDate.text = [NSString stringWithFormat:@"On: %@", [dateFormat stringFromDate:myIOU.date]];
    
    lblNotes.text = @"Notes:";
    lblNotesValue.text = myIOU.notes;
    
    NSNumberFormatter *numformatter = [[NSNumberFormatter alloc] init];
    [numformatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numformatter setNegativeFormat:@"-¤#,##0.00"];
    lblTotalBalanceValue.text = [NSString stringWithFormat:@"%@", [numformatter stringFromNumber:[myIOU getTotalBalance]]];
    if([[myIOU getTotalBalance] floatValue] < 0) {
        lblTotalBalanceValue.textColor = [UIColor redColor];
    }
    else {
        lblTotalBalanceValue.textColor = [UIColor blackColor];
    }
    
    NSDecimalNumber *unpaid = [myIOU getOutstandingBalance];
    if([unpaid floatValue] < 0) {
        unpaid = [unpaid decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithInt:-1]];
    }
    lblBalanceLeft.text = [NSString stringWithFormat:@"(%@ unpaid)", [numformatter stringFromNumber:unpaid]];
    
    [tblPeople removeFromSuperview];
    tblPeople = [[UITableView alloc] initWithFrame:CGRectMake(0, 220, self.view.frame.size.width, CELL_HEIGHT * (myIOU.peopleLink.count + 1)) style:UITableViewStyleGrouped];
    tblPeople.backgroundColor = [UIColor clearColor];
    tblPeople.backgroundView = nil;
    tblPeople.delegate = self;
    tblPeople.dataSource = self;
    tblPeople.scrollEnabled = NO;
    [scrollView addSubview:tblPeople];
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, tblPeople.frame.origin.y + tblPeople.frame.size.height);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Button Handlers

-(void)editButtonTapped:(id)sender {
    EditIOUViewController *vc = [[EditIOUViewController alloc] initWithIOU:myIOU];
    vc.navController = self.navigationController;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                   initWithTitle: @"Cancel" 
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate functions

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return myIOU.peopleLink.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IOUPersonLink *pl = [[[myIOU.peopleLink allObjects] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row];
    
    NSString *cellIdent = @"Cell";
    CustomIOUCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    float percentPaid = [pl.amountPaid floatValue] / [[pl getAbsAmountOwed] floatValue];
    if(cell == nil) {
        cell = [[CustomIOUCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdent percentPaid:percentPaid];
    }
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    
    cell.primaryLabel.text = pl.person.name;
    cell.subLabel.text = [currencyFormatter stringFromNumber:[pl getAbsAmountOwed]];
    cell.rightSubLabel.text = [NSString stringWithFormat:@"%@ paid", [currencyFormatter stringFromNumber:pl.amountPaid]];
    if([pl.amountPaid floatValue] == [[pl getAbsAmountOwed] floatValue]) {
        // get date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"MM/dd/yyyy"];
        
        cell.rightLabel.text = [NSString stringWithFormat:@"paid %@", [dateFormatter stringFromDate:pl.paidOn]];
    }
    else {
        cell.rightLabel.text = @"";
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IOUPersonLink *pl = [[[myIOU.peopleLink allObjects] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row];
    
    PaymentViewController *vc = [[PaymentViewController alloc] initWithIOU:myIOU IOUPersonLink:pl lockPl:NO];
    vc.navController = self.navigationController;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                   initWithTitle: @"Cancel" 
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
