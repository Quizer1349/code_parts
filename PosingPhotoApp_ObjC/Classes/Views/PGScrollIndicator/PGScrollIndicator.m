//
//  PGScrollIndicator.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 19.06.15.
//  Copyright (c) 2015 mainsoft. All rights reserved.
//

#import "PGScrollIndicator.h"

@interface PGScrollIndicator (){

    UIImageView * _indicatorImage;
}

@end


@implementation PGScrollIndicator

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(id)initWithCoder:(NSCoder *)aDecoder{

    self = [super initWithCoder:aDecoder];
    if (self) {
        [self baseInitWithFrame:self.frame];
    }
    
    
    
    return self;
    
}

-(instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        [self baseInitWithFrame:frame];
    }
    
    
    
    return self;
    
}

-(void)baseInitWithFrame:(CGRect)frame{

    _indicatorImage  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scroll_indicator"]];
    _indicatorImage.backgroundColor = [UIColor clearColor];
    _indicatorImage.frame = CGRectMake(0.f, 0.f, frame.size.width, frame.size.height);
    
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:_indicatorImage];
    
    [self flashOn:_indicatorImage];

}

- (void)flashOff:(UIView *)v {
    
    if(!self.visible){
    
        return;
    }
    
    if(v.alpha < 1.0){
    
        return;
    }
    
    __weak PGScrollIndicator* weakSelf = self;
    
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        v.alpha = .3f;  //don't animate alpha to 0, otherwise you won't be able to interact with it
    } completion:^(BOOL finished) {
        [weakSelf flashOn:v];
    }];
}

- (void)flashOn:(UIView *)v {
    
    if(!self.visible){
        
        return;
    }
    
    if(v.alpha >= 0.5){
        
        return;
    }
    
    __weak PGScrollIndicator* weakSelf = self;
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        v.alpha = 1.f;
    } completion:^(BOOL finished) {
        [weakSelf flashOff:v];
    }];
}

-(void)setVisible:(BOOL)visible{

    _visible = visible;
    
    if(_visible){
        _indicatorImage.alpha = 1.0f;
        [self flashOff:_indicatorImage];
    }
}

@end
