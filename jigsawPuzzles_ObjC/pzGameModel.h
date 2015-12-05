//
//  pzGameModel.h
//  Puzzle
//
//  Created by Алекс Скляр on 10.11.13.
//  Copyright (c) 2013 AlexSkly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface pzGameModel : NSObject
{

@private
    NSMutableArray *_puzzlesArray;
    NSMutableArray *_coordinatesArray;
    NSInteger _puzzlesCount;
    NSInteger _puzzlesGridWidth;
    NSInteger _puzzlesGridHeight;
    CGFloat _puzzlePieceWidth;
    CGFloat _puzzlePieceHeight;
    UIBezierPath * _leftTopCorner;
    UIImage * _image;
}

@property (nonatomic, retain) NSMutableArray *puzzlesArray;
@property (strong, nonatomic) NSMutableArray *coordinatesArray;
@property (nonatomic) NSInteger puzzlesGridWidth;
@property (nonatomic) NSInteger puzzlesGridHeight;
@property (nonatomic) CGFloat puzzlePieceWidth;
@property (nonatomic) CGFloat puzzlePieceHeight;
@property (nonatomic) NSInteger puzzlesCount;
@property (nonatomic) UIBezierPath * leftTopCorner;
@property (nonatomic) UIImage * image;

- (UIImage *) setClippingPath:(UIBezierPath *)clippingPath cropImage:(UIImage *)image;

- (void) cropPuzzleGrip:(UIImage *)puzzleImage;

- (UIBezierPath *) setFigureSide:(NSInteger)pNum pathBefore:(UIBezierPath*)path withX:(CGFloat)startX withY:(CGFloat)startY rotateOn:(NSInteger)angle  isReverse:(BOOL)reverse;

@end