//
//  CustomCell.h
//  Track My Money
//
//  Created by Raymond Tam on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell {
    UILabel *primaryLabel;
    UILabel *subLabel;
    UILabel *rightLabel;
}

@property (nonatomic, retain) UILabel *primaryLabel;
@property (nonatomic, retain) UILabel *subLabel;
@property (nonatomic, retain) UILabel *rightLabel;


@end
