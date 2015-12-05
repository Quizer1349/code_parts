//
//  PagedImageScrollView.m
//  Test
//
//  Created by jianpx on 7/11/13.
//  Copyright (c) 2013 PS. All rights reserved.
//

#import "PGFullPhotoView.h"

@interface PGFullPhotoView() <UIScrollViewDelegate>
@property (nonatomic) BOOL pageControlIsChangingPage;
@property (nonatomic, weak) NSString *currentSide;
@property (nonatomic, strong) UIButton *leftArrowButton;
@property (nonatomic, strong) UIButton *rightArrowButton;

@end

@implementation PGFullPhotoView


#define PAGECONTROL_DOT_WIDTH 20
#define PAGECONTROL_HEIGHT 20

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
        self.pageControl = [[UIPageControl alloc] init];
        [self setDefaults];
        [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.scrollView];
      //  [self addSubview:self.pageControl];
        self.scrollView.delegate = self;
    }
    return self;
}


- (void)setPageControlPos:(enum PageControlPosition)pageControlPos {
    
    CGFloat width = PAGECONTROL_DOT_WIDTH * self.pageControl.numberOfPages;
    _pageControlPos = pageControlPos;
    

    if (pageControlPos == PageControlPositionRightCorner)
    {
        self.pageControl.frame = CGRectMake(self.scrollView.frame.size.width - width, self.scrollView.frame.size.height - PAGECONTROL_HEIGHT, width, PAGECONTROL_HEIGHT);
    }else if (pageControlPos == PageControlPositionCenterBottom)
    {
        self.pageControl.frame = CGRectMake((self.scrollView.frame.size.width - width) / 2, self.scrollView.frame.size.height - PAGECONTROL_HEIGHT, width, PAGECONTROL_HEIGHT);
    }else if (pageControlPos == PageControlPositionLeftCorner)
    {
        self.pageControl.frame = CGRectMake(0, self.scrollView.frame.size.height - PAGECONTROL_HEIGHT, width, PAGECONTROL_HEIGHT);
    }
}

- (void)setDefaults {
    
    self.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    self.pageControl.hidesForSinglePage = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.pageControlPos = PageControlPositionRightCorner;
}


- (void)setScrollViewContents: (id)images {
    
    //remove original subviews first.
    for (UIView *subview in [self.scrollView subviews]) {
        [subview removeFromSuperview];
    }
    
    if ([images isKindOfClass:[NSArray class]]) {
        
        if ([(NSArray *)images count] <= 0) {
            self.pageControl.numberOfPages = 0;
            return;
        }
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [(NSArray *)images count], self.scrollView.frame.size.height);
        
        for (int i = 0; i < [(NSArray *)images count]; i++) {
            UIImageView *photoRuleIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:const_fileName_ruleCorrectIcon]];
            [photoRuleIndicator setFrame:CGRectMake(270.f, 25.f, 35.f, 35.f)];
        
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width * i, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
            [imageView setImage:images[i]];
            //[imageView setContentMode:UIViewContentModeScaleAspectFit];
            [self.scrollView addSubview:imageView];
        }
        
        self.pageControl.numberOfPages = [(NSArray *)images count];
    }else if([images isKindOfClass:[NSDictionary class]]){
        
        if ([(NSDictionary *)images count] <= 0) {
            self.pageControl.numberOfPages = 0;
            return;
        }
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [(NSDictionary *)images count], self.scrollView.frame.size.height);
        
        __block int i = 0;
        [(NSDictionary *)images enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            UIImageView *photoRuleIndicator = [[UIImageView alloc] init];
            
            if ([key isEqualToString:@"false"]) {

               photoRuleIndicator.image = [UIImage imageNamed:const_fileName_ruleIncorrectIcon];

            }else if ([key isEqualToString:@"true"]){

               photoRuleIndicator.image = [UIImage imageNamed:const_fileName_ruleCorrectIcon];
            }
            
            if (IS_IPAD()) {
                [photoRuleIndicator setFrame:CGRectMake(self.scrollView.frame.size.width * (i + 1) - 80.f, 25.f, 60.f, 60.f)];
            }else{
                [photoRuleIndicator setFrame:CGRectMake(self.scrollView.frame.size.width * (i + 1) - 50.f, 25.f, 35.f, 35.f)];
            }

            UIImageView *imageView = [[UIImageView alloc]
                                      initWithFrame:CGRectMake(self.scrollView.frame.size.width * i, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
            [imageView setImage:obj];
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            [self.scrollView addSubview:imageView];
            /*Alway on top*/
            [self.scrollView addSubview:photoRuleIndicator];

            i++;
        }];
        
        [self addSideNavigationButtons];
        self.pageControl.numberOfPages = [(NSDictionary *)images count];
    }


    //call pagecontrolpos setter.
    self.pageControlPos = self.pageControlPos;
}

#pragma mark - Navigation Buttons

- (void)addSideNavigationButtons{
    
    self.leftArrowButton = [[UIButton alloc] initWithFrame:CGRectMake(15.f, DEVICE_HEIGHT / 2 - 17.f, 14.f, 34.f)];
    [self.leftArrowButton setImage:[UIImage imageNamed:@"photo-arrow-left"] forState:UIControlStateNormal];
    [self.leftArrowButton addTarget:self action:@selector(changePageByButtonLeft) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.leftArrowButton];
    
    self.rightArrowButton = [[UIButton alloc] initWithFrame:CGRectMake(DEVICE_WIDTH - 29.f, DEVICE_HEIGHT / 2 - 17.f, 14.f, 34.f)];
    [self.rightArrowButton setImage:[UIImage imageNamed:@"photo-arrow-right"] forState:UIControlStateNormal];
    [self.rightArrowButton addTarget:self action:@selector(changePageByButtonRight) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: self.rightArrowButton];

}

- (void)changePageByButtonLeft{
 
    self.rightArrowButton.hidden = NO;
    
    int page = (int)self.pageControl.currentPage - 1;
    [self scrollToPage:page animated:YES];
    
}

- (void)changePageByButtonRight{
    
    self.leftArrowButton.hidden = NO;
    
    int page = (int)self.pageControl.currentPage + 1;
    [self scrollToPage:page animated:YES];

    
}

#pragma mark - Scroll Pages Mathods

- (void)scrollToPage:(int)page animated:(BOOL)animated {

    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:animated];
    [self.pageControl setCurrentPage:page];
    self.pageControlIsChangingPage = YES;
    
    
    [self setSideControlState];
}

- (void)changePage:(UIPageControl *)sender {
    
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    self.pageControlIsChangingPage = YES;
    
    
    [self setSideControlState];
}

#pragma scrollviewdelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.pageControlIsChangingPage) {

        return;
    }
    CGFloat pageWidth = scrollView.frame.size.width;
    //switch page at 50% across
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    [self setSideControlState];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    self.pageControlIsChangingPage = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    self.pageControlIsChangingPage = NO;
}

-(void)setSideControlState {

    if(self.pageControl.currentPage == (self.pageControl.numberOfPages - 1)){
        self.rightArrowButton.hidden = YES;
        self.leftArrowButton.hidden = NO;
    }else if (self.pageControl.currentPage == 0){
        self.leftArrowButton.hidden = YES;
        self.rightArrowButton.hidden = NO;
    }
}

@end
