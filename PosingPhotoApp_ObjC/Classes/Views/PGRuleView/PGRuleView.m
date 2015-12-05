//
//  PGRuleView.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 23.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGRuleView.h"
#import "Rule.h"
#import "PGFullPhotoViewController.h"
#import "UIImage+Resize.h"


@interface PGRuleView(){

    BOOL _isConfigured;
}

@end


@implementation PGRuleView

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
    if(Is4Inches()){
        [[NSBundle mainBundle] loadNibNamed:RETINA4_FILENAME( NSStringFromClass([self class]), RETINA4_PREFIX) owner:self options:nil];
    }else{
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    }
    
//    [self.leftNavArrow setBackgroundImage:[UIImage imageNamed:@"rule-arrow-left"] forState:UIControlStateNormal];
//    [self.rightNavArrow setBackgroundImage:[UIImage imageNamed:@"rule-arrow-right"] forState:UIControlStateNormal];

    [self setAutoresizesSubviews:YES];
    [self.view setAutoresizesSubviews:YES];
    
    
    for (UIView *subView in self.view.subviews) {
        
        subView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |
                                   UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                   UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        if(subView.subviews.count > 0){
            for (UIView *subViewSecondLevel in subView.subviews) {
                subViewSecondLevel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |
                                                      UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                                      UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            }
        }
    }
    
    if (!CGRectIsEmpty(self.frame)) {
//        DLog(@"ruleTitleLabel.font - %@", self.ruleTitleLabel.font);
//        if (IS_IPAD()) {
//            self.ruleTitleLabel.font = [UIFont fontWithName:@"TaurusLightNormal" size:20.0f];
//        }else{
//            self.ruleTitleLabel.font = [UIFont fontWithName:@"TaurusLightNormal" size:15.0f];
//        }
        self.ruleDescription.editable = YES;
        if (IS_IPAD()) {
            self.ruleDescription.font = [UIFont fontWithName:@"Times New Roman" size:14.5f];
        }else{
            self.ruleDescription.font = [UIFont fontWithName:@"Times New Roman" size:15.5f/(WIDTH(self.view)/WIDTH(self))];
        }

        self.ruleDescription.editable = NO;
        self.ruleDescription.textAlignment = NSTextAlignmentCenter;
        
        if(Is3_5Inches())
            self.ruleDescription.frame = CGRectMake(X(self.ruleDescription), Y(self.ruleDescription) - 8.f, WIDTH(self.ruleDescription), HEIGHT(self.ruleDescription) + 30.f);
        
        [self.view setFrame:self.bounds];
    }else{
        self.ruleDescription.editable = YES;
        
        if (IS_IPAD()) {
            
            self.ruleTitleLabel.font = [UIFont fontWithName:@"TaurusLightNormal" size:32.0f];
            self.ruleDescription.font = [UIFont fontWithName:@"Times New Roman" size:24.0f];
        }else{

            self.ruleDescription.font = [UIFont fontWithName:@"Times New Roman" size:15.5f];
        }

        self.ruleDescription.editable = NO;
        self.ruleDescription.textAlignment = NSTextAlignmentCenter;
        [self setFrame:self.view.frame];
    }
    [self addSubview:self.view];
    
    if(IS_IPAD()){
        self.topImageView.frame = CGRectMake(X(self.topImageView) + 5.f, Y(self.topImageView) - 5.f, WIDTH(self.topImageView) - 10.f, HEIGHT(self.topImageView) + 5.f);
        self.bottomImageView.frame = CGRectMake(X(self.bottomImageView) + 5.f, Y(self.bottomImageView) - 5.f, WIDTH(self.bottomImageView)  - 10.f, HEIGHT(self.bottomImageView) + 5.f);
        
        self.landTopBG.frame = self.topImageView.frame;
        self.landBottomBG.frame = self.bottomImageView.frame;
        
        
        self.leftImageView.frame = CGRectMake(X(self.leftImageView) - 15.f, Y(self.leftImageView), WIDTH(self.leftImageView) + 20.f, HEIGHT(self.leftImageView) + 10.f);
        self.rightImageView.frame = CGRectMake(X(self.rightImageView) - 5.f, Y(self.rightImageView), WIDTH(self.rightImageView) + 20.f, HEIGHT(self.rightImageView) + 10.f);
        
        self.portraitLeftBG.frame = self.leftImageView.frame;
        self.portraitRightBG.frame = self.rightImageView.frame;
        
    }

    
}

-(void)prepareForReuse{

    self.leftImageView.image = nil;
    self.rightImageView.image = nil;
    
    self.topImageView.image = nil;
    self.bottomImageView.image = nil;
    
    self.ruleTitleLabel.text = nil;
    self.ruleDescription.text = nil;
    
}

-(void)setRule:(Rule *)rule {

    if(![rule isEqual:_rule]){
        
        [self prepareForReuse];
        _rule = rule;
        
        self.titleLabel.text = F(NSLocalizedString(const_local_ruleNumberTitle, nil), [_rule.ruleId stringValue]);
        self.ruleTitleLabel.text = _rule.ruleTitle;
        self.ruleDescription.text = _rule.ruleDescriprion;
        self.ruleDescription.selectable = NO;
        self.ruleDescription.editable = NO;
        
        @autoreleasepool {
            

            __block UIImage *falseImage = [[UIImage alloc] init];
            __block UIImage *trueImage = [[UIImage alloc] init];
            
            
//            falseImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:F(@"%@@2x" ,_rule.falseImage) ofType:@"png"]];
//            trueImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:F(@"%@@2x", _rule.trueImage) ofType:@"png"]];
            
            
            
            __weak PGRuleView *weakSelf = self;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
                
                falseImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:F(@"%@@2x" ,_rule.falseImage) ofType:@"png"]];
                trueImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:F(@"%@@2x", _rule.trueImage) ofType:@"png"]];
                
                CGSize cropSize;
                if((falseImage.size.width > falseImage.size.height) & (trueImage.size.width > trueImage.size.height)){
                    cropSize = weakSelf.topImageView.bounds.size;
                }else{
                    cropSize = weakSelf.leftImageView.bounds.size;
                }
                
                falseImage = [falseImage resizedImageToFitInSize:cropSize scaleIfSmaller:YES];
                trueImage = [trueImage resizedImageToFitInSize:cropSize scaleIfSmaller:YES];
                
                dispatch_async(dispatch_get_main_queue(), ^{

                    if((falseImage.size.width > falseImage.size.height) & (trueImage.size.width > trueImage.size.height)){
                        
                        self.leftImageView.image = nil;
                        self.rightImageView.image = nil;
                        
                        self.topImageView.image = falseImage;
                        self.bottomImageView.image = trueImage;
                        
                        self.portraitPhotoWrapper.hidden = YES;
                        self.landscapePhotoWrapper.hidden = NO;
                        
                        if(Is3_5Inches()){
                            if(HEIGHT(self.descrView) > 133.f){
                                self.descrView.frame = CGRectMake(X(self.descrView), Y(self.descrView) + 25.f, WIDTH(self.descrView), HEIGHT(self.descrView) - 25.f);
                            }
                        }
                        
                    }else{
                        
                        self.leftImageView.image = falseImage;
                        self.rightImageView.image = trueImage;
                        
                        
                        self.topImageView.image = nil;
                        self.bottomImageView.image = nil;
                        
                        self.portraitPhotoWrapper.hidden = NO;
                        self.landscapePhotoWrapper.hidden = YES;
                        
                        if(Is3_5Inches()){
                            if(HEIGHT(self.descrView) < 158.f){
                                self.descrView.frame = CGRectMake(X(self.descrView), Y(self.descrView) - 25.f, WIDTH(self.descrView), HEIGHT(self.descrView) + 25.f);
                            }
                        }
                    }
                    [self configureGeusterForImages];
                });

            });
            
            //falseImage = [UIImage imageNamed:_rule.falseImage];//:[[NSBundle mainBundle] pathForResource:F(@"%@@2x" ,_rule.falseImage) ofType:@"png"]];
            //trueImage = [UIImage imageNamed:_rule.trueImage];//[[NSBundle mainBundle] pathForResource:F(@"%@@2x", _rule.trueImage) ofType:@"png"]];
            
            

        }

        //DLog(@"self.sescrView.frame - %@", NSStringFromCGRect(self.ruleDescription.frame));
        
        //[self setNeedsDisplay];
    }
}


-(void)addViewToViewController:(UIViewController<PGRuleViewDelegate> *)viewController {

    self.titleBarView.hidden = YES;
    self.bgImageView.hidden = YES;
    self.leftNavArrow.hidden = NO;
    self.rightNavArrow.hidden = NO;
    
    UIColor *imagesBorderColor = [UIColor colorWithRed:49.f/255.f green:143.f/255.f blue:186.f/255.f alpha:1.f];
    
    [self.topImageView.layer setBorderWidth:0.3f];
    [self.topImageView.layer setBorderColor:imagesBorderColor.CGColor];
    
    [self.bottomImageView.layer setBorderWidth:0.3f];
    [self.bottomImageView.layer setBorderColor:imagesBorderColor.CGColor];
    
    [self.leftImageView.layer setBorderWidth:0.3f];
    [self.leftImageView.layer setBorderColor:imagesBorderColor.CGColor];
    
    [self.rightImageView.layer setBorderWidth:0.3f];
    [self.rightImageView.layer setBorderColor:imagesBorderColor.CGColor];
    
    self.center = CGPointMake(self.center.x, self.center.y);
    
    if(!IS_IPAD()){
        self.ruleTitleLabel.font = [UIFont fontWithName:@"TaurusLightNormal" size:18.0f];;
    }
    
    if(!_isConfigured){
        
        if(Is3_5Inches()){
            
            self.ruleDescription.frame = CGRectMake(X(self.ruleDescription), Y(self.ruleDescription), WIDTH(self.ruleDescription), HEIGHT(self.ruleDescription) + 20.f);
            _isConfigured = YES;
            
        }else{
            
            self.ruleDescription.frame = CGRectMake(X(self.ruleDescription), Y(self.ruleDescription), WIDTH(self.ruleDescription), HEIGHT(self.ruleDescription) + 10.f);
            _isConfigured = YES;

        }
    }

    if(IS_IPAD()){
        self.topImageView.frame = CGRectMake(X(self.topImageView), Y(self.topImageView) - 5.f, WIDTH(self.topImageView), HEIGHT(self.topImageView));
    }
    
    [viewController.view addSubview:self];
    [viewController.view bringSubviewToFront:self];
    
    self.delegate = viewController;
}

- (IBAction)leftArrowPressed:(id)sender {
    
    if (!self.delegate) {
        return;
    }
    [self.delegate ruleView:self loadRuleWithId:[self.rule.ruleId intValue] - 1];
}

- (IBAction)rightArrowPressed:(id)sender {

    if (!self.delegate) {
        return;
    }
   
    [self.delegate ruleView:self loadRuleWithId:[self.rule.ruleId intValue] + 1];

}

-(void)configureGeusterForImages{
    
    self.topImageView.userInteractionEnabled = YES;
    self.bottomImageView.userInteractionEnabled = YES;
    self.leftImageView.userInteractionEnabled = YES;
    self.rightImageView.userInteractionEnabled = YES;
    
    if (self.topImageView.image && self.bottomImageView.image) {
        [self.topImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapedFalse:)]];
        [self.bottomImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapedRight:)]];
    }else if(self.leftImageView.image && self.rightImageView.image){
        [self.leftImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapedFalse:)]];
        [self.rightImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapedRight:)]];

    }
}

#pragma mark - geuster handler

-(void)imageTapedFalse:(id)sender {
    
    PGFullPhotoViewController *fullPhotoVC = [[PGFullPhotoViewController alloc] init];
    fullPhotoVC.imagesDictionary = [self wrapPhotosForFullView];
    fullPhotoVC.currentPhoto = 1;
    
    [self.delegate presentViewController:fullPhotoVC animated:YES completion:nil];
}

-(void)imageTapedRight:(id)sender {
    
   
    
    PGFullPhotoViewController *fullPhotoVC = [[PGFullPhotoViewController alloc] init];
    fullPhotoVC.imagesDictionary = [self wrapPhotosForFullView];
    fullPhotoVC.currentPhoto = 2;
    
    [self.delegate presentViewController:fullPhotoVC animated:YES completion:nil];
}

-(NSDictionary *)wrapPhotosForFullView {

    NSMutableDictionary *imagesToFull = [NSMutableDictionary dictionary];
//    NSString *deviceType = [NSString string];
//    
//    if (Is4Inches()) {
//        deviceType = @"iphone5";
//    }else if(Is3_5Inches()) {
//        deviceType = @"iphone4";
//    }else if (IS_IPAD()){
//        deviceType = @"ipad";
//    }
    
    UIImage *ruleFalseFullImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:F(@"%@@2x" ,_rule.falseImage) ofType:@"png"]];
    UIImage *ruleTrueFullImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:F(@"%@@2x", _rule.trueImage) ofType:@"png"]];
    [imagesToFull addEntriesFromDictionary:@{@"false":ruleFalseFullImage, @"true":ruleTrueFullImage}];
    
//    if (self.topImageView.image && self.bottomImageView.image) {
//        UIImage *ruleFalseFullImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-full" , self.rule.falseImage]];
//        [imagesToFull addEntriesFromDictionary:@{@"true":self.bottomImageView.image, @"false":self.topImageView.image}];
//    }else if(self.leftImageView.image && self.rightImageView.image){
//        [imagesToFull addEntriesFromDictionary:@{@"true":self.rightImageView.image, @"false":self.leftImageView.image}];
//    }
    
    return imagesToFull;
}
@end
