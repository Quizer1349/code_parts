//
//  pzViewController.h
//  Puzzle
//
//  Created by Алекс Скляр on 10.11.13.
//  Copyright (c) 2013 AlexSkly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "pzGameModel.h"

@interface pzViewController : UIViewController
{
    UIImageView *puzzlesBundle;
    pzGameModel *gameModel;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
