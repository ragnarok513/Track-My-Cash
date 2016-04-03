//
//  CustomCell.m
//  Track My Money
//
//  Created by Raymond Tam on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell 
@synthesize primaryLabel, subLabel, rightLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGRect contentRect = self.contentView.bounds;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        primaryLabel = [[UILabel alloc]init];
        primaryLabel.textAlignment = UITextAlignmentLeft;
        primaryLabel.font = DEFAULT_FONT(17);
        primaryLabel.highlightedTextColor = [UIColor whiteColor];
        primaryLabel.backgroundColor = [UIColor clearColor];
        primaryLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        primaryLabel.frame = CGRectMake(contentRect.origin.x + 10, 2, (contentRect.size.width * 2 / 3) - 11, 25);

        subLabel = [[UILabel alloc]init];        
        subLabel.textAlignment = UITextAlignmentLeft;
        subLabel.font = DEFAULT_FONT(14);
        subLabel.textColor = [UIColor grayColor];
        subLabel.highlightedTextColor = [UIColor whiteColor];
        subLabel.backgroundColor = [UIColor clearColor];
        subLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        subLabel.frame = CGRectMake(contentRect.origin.x + 10, 27, (contentRect.size.width * 2 / 3) - 11, 12);

        rightLabel = [[UILabel alloc]init];        
        rightLabel.textAlignment = UITextAlignmentRight;
        rightLabel.font = DEFAULT_FONT(16);
        rightLabel.textColor = [UIColor blackColor];;
        rightLabel.highlightedTextColor = [UIColor whiteColor];
        rightLabel.backgroundColor = [UIColor clearColor];
        rightLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        rightLabel.frame = CGRectMake(contentRect.size.width - 210, 0, 200, contentRect.size.height);
        
        [self.contentView addSubview:primaryLabel];
        [self.contentView addSubview:subLabel];
        [self.contentView addSubview:rightLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
