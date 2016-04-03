//
//  CustomIOUCell.h
//  TrackMyCash
//
//  Created by Ray Tam on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomIOUCell : UITableViewCell {
    UILabel *primaryLabel;
    UILabel *subLabel;
    UILabel *rightLabel;
    UILabel *rightSubLabel;
}

@property (nonatomic, retain) UILabel *primaryLabel;
@property (nonatomic, retain) UILabel *subLabel;
@property (nonatomic, retain) UILabel *rightLabel;
@property (nonatomic, retain) UILabel *rightSubLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier percentPaid:(float)percentPaid;

@end
