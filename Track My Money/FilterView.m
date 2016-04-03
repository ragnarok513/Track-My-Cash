//
//  FilterView.m
//  TrackMyCash
//
//  Created by Ray Tam on 8/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FilterView.h"
#import "IOUsViewController.h"
#import "PeopleViewController.h"
#import "PersonDetailsViewController.h"

typedef enum {
    Filter,
    Sorter
} FilterSections;

@interface FilterView () {
    BOOL isExpanded;
    BOOL isLocked;
    FilterSections currentSection;
}

@end

@implementation FilterView

@synthesize delegate, currentFilter, currentSort;

- (id)initWithFrame:(CGRect)frame withClass:(UIViewController *)vc
{
    self = [super initWithFrame: frame];
    if (self) {
        // Custom initialization
        self.backgroundColor = [UIColor lightGrayColor];
        arFilters = [[NSMutableArray alloc] init];
        arSorts = [[NSMutableArray alloc] init];
        
        isExpanded = NO;
        isLocked = NO;
        currentSection = Filter;
        
        if([vc class] == [IOUsViewController class]) {
            [arFilters addObject:[NSNumber numberWithInt:AllIOUs]];
            [arFilters addObject:[NSNumber numberWithInt:ActiveIOUs]];
            [arFilters addObject:[NSNumber numberWithInt:CompletedIOUs]];
            [arFilters addObject:[NSNumber numberWithInt:ILoanedOutMoney]];
            [arFilters addObject:[NSNumber numberWithInt:IBorrowedMoney]];
            
            [arSorts addObject:[NSNumber numberWithInt:Title]];
            [arSorts addObject:[NSNumber numberWithInt:Newest]];
            [arSorts addObject:[NSNumber numberWithInt:Oldest]];
            [arSorts addObject:[NSNumber numberWithInt:LargestBalance]];
            [arSorts addObject:[NSNumber numberWithInt:SmallestBalance]];
            
            currentFilter = (FilterTypes *)[[arFilters objectAtIndex:0] intValue];
            currentSort = (SortTypes *)[[arSorts objectAtIndex:0] intValue];
        }
        else if([vc class] == [PeopleViewController class]) {
            [arFilters addObject:[NSNumber numberWithInt:AllPeople]];
            [arFilters addObject:[NSNumber numberWithInt:WithActiveIOUs]];
            [arFilters addObject:[NSNumber numberWithInt:WithNoActiveIOUs]];
            [arFilters addObject:[NSNumber numberWithInt:OwesMeMoney]];
            [arFilters addObject:[NSNumber numberWithInt:IOweMoney]];
            
            [arSorts addObject:[NSNumber numberWithInt:Name]];
            [arSorts addObject:[NSNumber numberWithInt:MostActiveIOUs]];
            [arSorts addObject:[NSNumber numberWithInt:LargestBalance]];
            [arSorts addObject:[NSNumber numberWithInt:SmallestBalance]];
            
            currentFilter = (FilterTypes *)[[arFilters objectAtIndex:1] intValue];
            currentSort = (SortTypes *)[[arSorts objectAtIndex:0] intValue];
        }
        else if([vc class] == [PersonDetailsViewController class]) {
            [arFilters addObject:[NSNumber numberWithInt:AllIOUs]];
            [arFilters addObject:[NSNumber numberWithInt:DebtSettled]];
            [arFilters addObject:[NSNumber numberWithInt:DebtUnsettled]];
            [arFilters addObject:[NSNumber numberWithInt:OwesMeMoney]];
            [arFilters addObject:[NSNumber numberWithInt:IOweMoney]];
            
            [arSorts addObject:[NSNumber numberWithInt:Title]];
            [arSorts addObject:[NSNumber numberWithInt:LargestBalance]];
            [arSorts addObject:[NSNumber numberWithInt:SmallestBalance]];
            [arSorts addObject:[NSNumber numberWithInt:Paid]];
            [arSorts addObject:[NSNumber numberWithInt:Unpaid]];
            
            currentFilter = (FilterTypes *)[[arFilters objectAtIndex:2] intValue];
            currentSort = (SortTypes *)[[arSorts objectAtIndex:0] intValue];
        }
        
        UIImage *imgDownArrow = [UIImage imageNamed:@"downArrow.png"];
        imgDropShadow = [UIImage imageNamed:@"dropshadow.png"];
        
        tblFiltersSorts = [[UITableView alloc] initWithFrame:CGRectMake(0, FILTERBAR_HEIGHT, self.frame.size.width, 0) style:UITableViewStylePlain];
        tblFiltersSorts.scrollEnabled = NO;
        tblFiltersSorts.backgroundColor = [UIColor lightGrayColor];
        tblFiltersSorts.separatorStyle = UITableViewCellSeparatorStyleNone;
        tblFiltersSorts.delegate = self;
        tblFiltersSorts.dataSource = self;
        [self addSubview:tblFiltersSorts];
        
        imgViewDropShadow = [[UIImageView alloc] initWithImage:imgDropShadow];
        imgViewDropShadow.frame = CGRectMake(0, FILTERBAR_HEIGHT - imgDropShadow.size.height, self.frame.size.width, imgDropShadow.size.height);
        imgViewDropShadow.alpha = 0;
        [self addSubview:imgViewDropShadow];
        
        lblFilter = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width / 2 - imgDownArrow.size.width - 15, FILTERBAR_HEIGHT)];
        lblFilter.text = [NSString stringWithFormat:@"Filter (%@)", [FilterView StringifyFilterType:currentFilter]];
        lblFilter.backgroundColor = [UIColor clearColor];
        lblFilter.textAlignment = UITextAlignmentCenter;
        lblFilter.font = DEFAULT_FONT(16);
        [self addSubview:lblFilter];
        
        UIImageView *imgViewFilterDownArrow = [[UIImageView alloc] initWithImage:imgDownArrow];
        imgViewFilterDownArrow.frame = CGRectMake(self.frame.size.width / 2 - imgDownArrow.size.width - 5, self.frame.size.height / 2 - imgDownArrow.size.height / 2, imgDownArrow.size.width, imgDownArrow.size.height);
        [self addSubview:imgViewFilterDownArrow];
        
        UIButton *btnFilter = [UIButton buttonWithType:UIButtonTypeCustom];
        btnFilter.frame = CGRectMake(0, 0, self.frame.size.width / 2, FILTERBAR_HEIGHT);
        [btnFilter addTarget:self action:@selector(filterDropDownClicked:) forControlEvents:UIControlEventTouchUpInside];
        btnFilter.backgroundColor = [UIColor clearColor];
        [self addSubview:btnFilter];
        
        lblSorter = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 + 10, 0, self.frame.size.width / 2 - imgDownArrow.size.width - 15, FILTERBAR_HEIGHT)];
        lblSorter.text = [NSString stringWithFormat:@"Sort (%@)", [FilterView StringifySortType:currentSort]];
        lblSorter.backgroundColor = [UIColor clearColor];
        lblSorter.textAlignment = UITextAlignmentCenter;
        lblSorter.font = DEFAULT_FONT(16);
        [self addSubview:lblSorter];
        
        UIImageView *imgViewSorterDownArrow = [[UIImageView alloc] initWithImage:imgDownArrow];
        imgViewSorterDownArrow.frame = CGRectMake(self.frame.size.width - imgDownArrow.size.width - 5, self.frame.size.height / 2 - imgDownArrow.size.height / 2, imgDownArrow.size.width, imgDownArrow.size.height);
        [self addSubview:imgViewSorterDownArrow];
        
        UIButton *btnSorter = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSorter.frame = CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, FILTERBAR_HEIGHT);
        [btnSorter addTarget:self action:@selector(sorterDropDownClicked:) forControlEvents:UIControlEventTouchUpInside];
        btnSorter.backgroundColor = [UIColor clearColor];
        [self addSubview:btnSorter];
        
        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - 1, 0, 2, FILTERBAR_HEIGHT)];
        seperator.backgroundColor = [UIColor blackColor];
        [self addSubview:seperator];
        
        UIView *bottomDivider = [[UIView alloc] initWithFrame:CGRectMake(0, FILTERBAR_HEIGHT - 1, self.frame.size.width, 1)];
        bottomDivider.backgroundColor = [UIColor blackColor];
        [self addSubview:bottomDivider];
    }
    return self;
}

#pragma mark - UITableViewDelegate functions

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.0f;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int count = 0;
    if(currentSection == Filter) {
        count = arFilters.count;
    }
    else if(currentSection == Sorter) {
        count = arSorts.count;
    }
    return count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdent = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdent];
    }
    
    [cell.textLabel setFont:DEFAULT_FONT(18)];
    
    if(currentSection == Filter) {
        int ft = [[arFilters objectAtIndex:indexPath.row] intValue];
        NSString *text = [FilterView StringifyFilterType:(FilterTypes *)ft];
        if(currentFilter == (FilterTypes *)ft) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", @"\u2022", text];
        }
        else {
            cell.textLabel.text = text;
        }
    }
    else if(currentSection == Sorter) {
        int st = [[arSorts objectAtIndex:indexPath.row] intValue];
        NSString *text = [FilterView StringifySortType:(SortTypes *)st];
        if(currentSort == (SortTypes *)st) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", @"\u2022", text];
        }
        else {
            cell.textLabel.text = text;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(currentSection == Filter) {
        int ft = [[arFilters objectAtIndex:indexPath.row] intValue];
        currentFilter = (FilterTypes *)ft;
        lblFilter.text = [NSString stringWithFormat:@"Filter (%@)", [FilterView StringifyFilterType:currentFilter]];
        [delegate filterOrSortDidChange];
         }
    else if(currentSection == Sorter) {
        int st = [[arSorts objectAtIndex:indexPath.row] intValue];
        currentSort = (SortTypes *)st;
        lblSorter.text = [NSString stringWithFormat:@"Sort (%@)", [FilterView StringifySortType:currentSort]];
        [delegate filterOrSortDidChange];
    }
    [self collapaseTableWithDuration:0.3f];
}

#pragma mark - Helper functions

-(void)resetView {
    [self collapaseTableWithDuration:0.0f];
    isExpanded = NO;
    isLocked = NO;
}

-(void)filterDropDownClicked:(id)sender {
    if(isExpanded) {
        [self collapaseTableWithDuration:0.3f];
        if(currentSection == Sorter) {
            currentSection = Filter;
            [tblFiltersSorts reloadData];
            [self expandTableWithDuration:0.3f];
        }
    }
    else {
        currentSection = Filter;
        [tblFiltersSorts reloadData];
        [self expandTableWithDuration:0.3f];
    }
}

-(void)sorterDropDownClicked:(id)sender {
    if(isExpanded) {
        [self collapaseTableWithDuration:0.3f];
        if(currentSection == Filter) {
            currentSection = Sorter;
            [tblFiltersSorts reloadData];
            [self expandTableWithDuration:0.3f];
        }
    }
    else {
        currentSection = Sorter;
        [tblFiltersSorts reloadData];
        [self expandTableWithDuration:0.3f];
    }
}

-(void)collapaseTableWithDuration:(float)duration {
    // collapse table
    isLocked = YES;
    [delegate didStartCollapsingWithDuration:duration];
    [UIView animateWithDuration:duration
                     animations:^{
                         tblFiltersSorts.frame = CGRectMake(0, FILTERBAR_HEIGHT, self.frame.size.width, 0);
                         imgViewDropShadow.alpha = 0;
                         imgViewDropShadow.frame = CGRectMake(0, FILTERBAR_HEIGHT - imgDropShadow.size.height, self.frame.size.width, imgDropShadow.size.height);
                         self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, FILTERBAR_HEIGHT);
                     }
                     completion:^(BOOL finished) {
                         isLocked = NO;
                         isExpanded = NO;
                     }]; 
}

-(void)expandTableWithDuration:(float)duration {
    // expand table
    isLocked = YES;
    [delegate didStartExpandingWithDuration:duration];
    [UIView animateWithDuration:duration
                     animations:^{
                         tblFiltersSorts.frame = CGRectMake(0, FILTERBAR_HEIGHT, self.frame.size.width, FILTERTABLE_HEIGHT);
                         imgViewDropShadow.alpha = 1;
                         imgViewDropShadow.frame = CGRectMake(0, FILTERTABLE_HEIGHT + FILTERBAR_HEIGHT - imgDropShadow.size.height, self.frame.size.width, imgDropShadow.size.height);
                         self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, FILTERBAR_HEIGHT + FILTERTABLE_HEIGHT);
                     }
                     completion:^(BOOL finished) {
                         isLocked = NO;
                         isExpanded = YES;
                     }]; 
}

+(NSString *)StringifyFilterType:(FilterTypes *)ft {
    switch((int)ft) {
        case AllIOUs:
            return @"All IOUs";
        case ActiveIOUs:
            return @"Active IOUs";
        case CompletedIOUs:
            return @"Completed IOUs";
        case ILoanedOutMoney:
            return @"I loaned out money";
        case IBorrowedMoney:
            return @"I borrowed money";
        case AllPeople:
            return @"All People";
        case WithActiveIOUs:
            return @"With Active IOUs";
        case WithNoActiveIOUs:
            return @"With No Active IOUs";
        case OwesMeMoney:
            return @"Owes Me Money";
        case IOweMoney:
            return @"I Owe Money";
        case DebtSettled:
            return @"Debt Settled";
        case DebtUnsettled:
            return @"Debt Unsettled";
    }
    return @"";
}

+(NSString *)StringifySortType:(SortTypes *)st {
    switch((int)st) {
        case Title:
            return @"Title";
        case Newest:
            return @"Newest";
        case Oldest:
            return @"Oldest";
        case LargestBalance:
            return @"Largest Balance";
        case SmallestBalance:
            return @"Smallest Balance";
        case Name:
            return @"Name";
        case MostActiveIOUs:
            return @"Most Active IOUs";
        case Paid:
            return @"Paid";
        case Unpaid:
            return @"Unpaid";
    }
    return @"";
}

@end
