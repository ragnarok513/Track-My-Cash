//
//  FilterView.h
//  TrackMyCash
//
//  Created by Ray Tam on 8/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterViewDelegate <NSObject>
-(void)didStartExpandingWithDuration:(float)duration;
-(void)didStartCollapsingWithDuration:(float)duration;
-(void)filterOrSortDidChange;
@end

@interface FilterView : UIView <UITableViewDelegate, UITableViewDataSource> {
    id<FilterViewDelegate> delegate;
    NSMutableArray *arFilters;
    NSMutableArray *arSorts;
    UIImage *imgDropShadow;
    UIImageView *imgViewDropShadow;
    UITableView *tblFiltersSorts;
    UILabel *lblFilter;
    UILabel *lblSorter;
    FilterTypes *currentFilter;
    SortTypes *currentSort;
}

@property (nonatomic, strong) id<FilterViewDelegate> delegate;
@property (nonatomic, assign) FilterTypes *currentFilter;
@property (nonatomic, assign) SortTypes *currentSort;

- (id)initWithFrame:(CGRect)frame withClass:(UIViewController *)vc;
- (void)resetView;
+ (NSString *)StringifyFilterType:(FilterTypes *)ft;
+ (NSString *)StringifySortType:(SortTypes *)st;

@end
