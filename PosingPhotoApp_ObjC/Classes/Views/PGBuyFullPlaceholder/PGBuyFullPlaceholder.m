//
//  PGBuyFullPlaceholder.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 22.05.15.
//  Copyright (c) 2015 mainsoft. All rights reserved.
//

#import "PGBuyFullPlaceholder.h"

@implementation PGBuyFullPlaceholder

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
    
    if(IS_IPAD()){
        
        self.textLabelIpad.text = labelText;
        [self setFrame:self.view_ipad.frame];
        [self addSubview:self.view_ipad];
        
    }else{
        
        self.textLabelIphone.text = labelText;
        [self setFrame:self.view_iphone.frame];
        [self addSubview:self.view_iphone];
    }
    
}

@end
