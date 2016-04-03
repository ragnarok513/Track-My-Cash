//
//  Constants.h
//  Track My Money
//
//  Created by Raymond Tam on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    AllIOUs = 0,
    ActiveIOUs = 1,
    CompletedIOUs = 2,
    ILoanedOutMoney = 3,
    IBorrowedMoney = 4,
    
    AllPeople = 5,
    WithActiveIOUs = 6,
    WithNoActiveIOUs = 7,
    OwesMeMoney = 8,
    IOweMoney = 9,
    
    DebtSettled = 10,
    DebtUnsettled = 11,
} FilterTypes;


typedef enum {
    Title = 1,
    Newest = 2,
    Oldest = 3,
    LargestBalance = 4,
    SmallestBalance = 5,
    
    Name = 6,
    MostActiveIOUs = 7,
    
    Paid = 8,
    Unpaid = 9
} SortTypes;




#define FILTERTABLE_HEIGHT 150
#define TABBARHEIGHT 93
#define KEYBOARD_TOOLBAR_HEIGHT 44
#define DEFAULT_HEADER_SIZE 16
#define FILTERBAR_HEIGHT 30
#define DEFAULT_FONT(s) [UIFont fontWithName:@"Nunito-Regular" size:(s)]
#define DEFAULT_FONT_BOLD(s) [UIFont fontWithName:@"Nunito-Bold" size:(s)]
#define DEFAULT_FONT_LIGHT(s) [UIFont fontWithName:@"Nunito-Light" size:(s)]
#define MY_BANNER_UNIT_ID @"XXXXXXXX"
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define WIDESCREEN_HEIGHT_DIFFERENCE 88

@interface Constants : NSObject

@end
