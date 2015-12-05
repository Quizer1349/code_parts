//
//  pzViewController.m
//  Puzzle
//
//  Created by Алекс Скляр on 10.11.13.
//  Copyright (c) 2013 AlexSkly. All rights reserved.
//

#import "pzViewController.h"



@implementation pzViewController

-(void)loadView {
    [super loadView];
    puzzlesBundle = [[UIImageView alloc] init];
    gameModel = [[pzGameModel alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //даем белый фон нашему self.view
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIImage *image = [UIImage imageNamed:@"puzzle.jpg"];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    image = [self imageWithImage:image scaledToSize:CGSizeMake(screenRect.size.height, screenRect.size.width)];
    //NSLog(@"Screen Width - %f, Screen Height - %f", screenRect.size.width, screenRect.size.height);
    [puzzlesBundle setImage:image];
    [puzzlesBundle setAlpha:0.5f];
    [puzzlesBundle setFrame:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height)];
    [puzzlesBundle setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:puzzlesBundle];
    
    //добавляем четыре части пазла
    [gameModel cropPuzzleGrip:image];
    for (NSUInteger i = 0; i < gameModel.puzzlesArray.count; i++) {
        UIImage *puzzleImage = [gameModel.puzzlesArray objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:puzzleImage];
        
        //устанавливаем рандомные координаты
        NSInteger rand_x = arc4random() % (int)(screenRect.size.height - puzzleImage.size.width);
        NSInteger rand_y = arc4random() % (int)(screenRect.size.width - puzzleImage.size.height);
        [imageView setFrame:CGRectMake(rand_x, rand_y, puzzleImage.size.width, puzzleImage.size.height)];
        //[imageView setBackgroundColor:[UIColor clearColor]];
        
        //теги решил использовать в качестве номерации кусочков пазла, что бы позже знать с какой именно частью мы работаем и с каким контрольным фреймом сравнивать
        [imageView setTag:i];
        [imageView setUserInteractionEnabled:YES];
        
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]; //добавляем возможность перетаскивания частей пазла
        [imageView addGestureRecognizer:gesture];
        imageView.layer.shadowColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5].CGColor;
        imageView.layer.shadowOffset = CGSizeMake(0, 1);
        imageView.layer.shadowOpacity = 1.0;
        imageView.layer.shadowRadius = 1;
        //imageView.layer.masksToBounds = NO;
        [self.view addSubview:imageView];
    }
}

-(void)handlePanGesture:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        //при клике выдвигаем кусок пазлаповерх всех остальных
        [self.view bringSubviewToFront:gesture.view];
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        //отслеживаем передвижение
        CGPoint dragPoint = [gesture locationInView:self.view];
        
        //и присваеваем нашему кусочку пазла новые координаты
        [gesture.view setFrame:CGRectMake(dragPoint.x - gesture.view.frame.size.width/2, dragPoint.y - gesture.view.frame.size.height/2, gesture.view.frame.size.width, gesture.view.frame.size.height)];
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        //что бы достать значение tag, которое мы задали в viewDidLoad прибегаем к принужденному переобразованию типов
        UIImageView *imageView = (UIImageView *)gesture.view;
        NSLog(@"%ld", (long)imageView.tag);
        //достаем нужный нам контрольный фрейм
        CGRect checkRect = [[gameModel.coordinatesArray objectAtIndex:imageView.tag] CGRectValue];
        
        //проверяем входит ли центр кусочка пазла в контрольный фрейм
        if (CGRectContainsPoint(checkRect, [self.view convertPoint:gesture.view.center toView:puzzlesBundle])) {
            
            //и если да, то ставим его на нужное место
            [gesture.view setCenter:CGPointMake(checkRect.origin.x + checkRect.size.width / 2, checkRect.origin.y + checkRect.size.height / 2)];
            [gesture.view.layer setShadowOffset:CGSizeMake(0, 0)];
            
            //и блокируем для дальнейших перетаскиваний
            [gesture.view setUserInteractionEnabled:NO];
            gameModel.puzzlesCount++;
        }
        
        if (gameModel.puzzlesCount == gameModel.puzzlesGridWidth * gameModel.puzzlesGridHeight) {
            NSLog(@"пазл сложен");
        }
        
    }
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
