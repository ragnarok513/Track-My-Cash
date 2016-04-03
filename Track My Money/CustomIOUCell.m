//
//  CustomIOUCell.m
//  TrackMyCash
//
//  Created by Ray Tam on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomIOUCell.h"

@implementation CustomIOUCell
@synthesize primaryLabel, subLabel, rightLabel, rightSubLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier percentPaid:(float)percentPaid
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGRect contentRect = self.contentView.bounds;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        // round percentPaid down to the nearest quarter
        int perc = ((int)(percentPaid*100/25))*25;
        
        // this means at least one payment was made, so give it at least 25 percent
        if(perc < 25 && percentPaid > 0) {
            perc = 25;
        }
        
        UIImage *imgMoney = [UIImage imageNamed:[NSString stringWithFormat:@"%ipercent.png", perc]];
        UIImageView *imgViewMoney = [[UIImageView alloc] initWithImage:imgMoney];
        imgViewMoney.frame = CGRectMake(contentRect.origin.x + 7, 12, imgMoney.size.width, imgMoney.size.height);
        [self.contentView addSubview:imgViewMoney];
        
        primaryLabel = [[UILabel alloc]init];
        primaryLabel.textAlignment = UITextAlignmentLeft;
        primaryLabel.font = DEFAULT_FONT(17);
        primaryLabel.highlightedTextColor = [UIColor whiteColor];
        primaryLabel.backgroundColor = [UIColor clearColor];
        primaryLabel.adjustsFontSizeToFitWidth = YES;
        primaryLabel.minimumFontSize = 14;
        primaryLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        primaryLabel.frame = CGRectMake(imgViewMoney.frame.origin.x + imgViewMoney.frame.size.width + 7, 2, (contentRect.size.width * 2 / 3) - 50, 25);
        
        subLabel = [[UILabel alloc]init];        
        subLabel.textAlignment = UITextAlignmentLeft;
        subLabel.adjustsFontSizeToFitWidth = YES;
        subLabel.minimumFontSize = 13;
        subLabel.font = DEFAULT_FONT(14);
        subLabel.textColor = [UIColor grayColor];
        subLabel.highlightedTextColor = [UIColor whiteColor];
        subLabel.backgroundColor = [UIColor clearColor];
        subLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        subLabel.frame = CGRectMake(imgViewMoney.frame.origin.x + imgViewMoney.frame.size.width + 7, 27, 160, 14);
        
        rightLabel = [[UILabel alloc]init];        
        rightLabel.textAlignment = UITextAlignmentRight;
        rightLabel.adjustsFontSizeToFitWidth = YES;
        rightLabel.font = DEFAULT_FONT(17);
        rightLabel.highlightedTextColor = [UIColor whiteColor];
        rightLabel.backgroundColor = [UIColor clearColor];
        rightLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        rightLabel.frame = CGRectMake(150, 2, 160, 25);
        
        rightSubLabel = [[UILabel alloc]init];        
        rightSubLabel.textAlignment = UITextAlignmentRight;
        rightSubLabel.adjustsFontSizeToFitWidth = YES;
        rightSubLabel.minimumFontSize = 13;
        rightSubLabel.alpha = 0.5;
        rightSubLabel.font = DEFAULT_FONT(14);
        rightSubLabel.textColor = [UIColor grayColor];
        rightSubLabel.highlightedTextColor = [UIColor whiteColor];
        rightSubLabel.backgroundColor = [UIColor clearColor];
        rightSubLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        rightSubLabel.frame = CGRectMake(subLabel.frame.size.width + subLabel.frame.origin.x - 40, 27, 160, 14);
        
        [self.contentView addSubview:primaryLabel];
        [self.contentView addSubview:subLabel];
        [self.contentView addSubview:rightLabel];
        [self.contentView addSubview:rightSubLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
