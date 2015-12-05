//
//  PGFavsTableCell.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 21.10.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGShareMenu.h"

@class iCarousel;
@class Favorites;
@protocol PGFavsTableCellDelegate;


@interface PGFavsTableCell : UITableViewCell

//@property (strong, nonatomic) Favorites *favItem;
@property (strong, nonatomic) NSArray *favsArray;

@property (weak, nonatomic) IBOutlet UILabel *poseTitleLabel;
@property (weak, nonatomic) IBOutlet iCarousel *imgScroller;
@property (weak, nonatomic) IBOutlet PGShareMenu *shareMenu;
@property (weak, nonatomic) IBOutlet UIButton *leftArrow;
@property (weak, nonatomic) IBOutlet UIButton *rightArrow;

@property (weak, nonatomic) id<PGFavsTableCellDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *imagesArray;


- (IBAction)leftArrowPressed:(id)sender;
- (IBAction)rightArrowPressed:(id)sender;

@end

@protocol PGFavsTableCellDelegate <NSObject>

@optional

- (void)cellView:(PGFavsTableCell *)cellView didSelectItemAtIndex:(NSInteger)index;
- (void)cellView:(PGFavsTableCell *)cellView curentItemAtIndex:(NSInteger)index;

@end
