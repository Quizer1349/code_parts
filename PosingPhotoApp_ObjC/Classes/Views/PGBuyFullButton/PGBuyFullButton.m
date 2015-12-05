//
//  PGBuyFullButton.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 22.05.15.
//  Copyright (c) 2015 mainsoft. All rights reserved.
//

#import "PGBuyFullButton.h"

@implementation PGBuyFullButton



- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self baseInit];
    }
    return self;
}

-(void)baseInit {
    
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];


    NSString *labelText = [NSLocalizedString(@"FULL VERSION", nil) lowercaseString];
    
    if(self.frame.size.width == 80.f){
    
        self.textLabelIphone.text = labelText;
        [self addSubview:self.view_iphone];
        
    }else if (self.frame.size.width == 165.f){
    
        
        self.textLabelIpad.text = labelText;
        [self addSubview:self.view_ipad];
        
    }
    
}

@end
