//
//  pzGameModel.m
//  Puzzle
//
//  Created by Алекс Скляр on 10.11.13.
//  Copyright (c) 2013 Alex Skly. All rights reserved.
//

#import "pzGameModel.h"
#import "math.h"

@implementation pzGameModel

@synthesize puzzlesArray = _puzzlesArray;
@synthesize coordinatesArray = _coordinatesArray;
@synthesize puzzlesCount = _puzzlesCount;
@synthesize leftTopCorner = _leftTopCorner;
@synthesize puzzlesGridWidth = _puzzlesGridWidth;
@synthesize puzzlesGridHeight = _puzzlesGridHeight;
@synthesize puzzlePieceWidth = _puzzlePieceWidth;
@synthesize puzzlePieceHeight = _puzzlePieceHeight;
@synthesize image = _image;

-(id)init {
    self = [super init];
    if (self) {
        self.puzzlesGridWidth = 6;
        self.puzzlesGridHeight = 4;
        [self setArraysData];
        self.puzzlesCount = 0;
    }
    return self;
}

-(void)setArraysData
{
    
    self.puzzlesArray = [[NSMutableArray alloc] init];

    self.coordinatesArray = [[NSMutableArray alloc] init];
    
}

- (UIImage *) setClippingPath:(UIBezierPath *)clippingPath cropImage:(UIImage *)image;
{
    UIGraphicsBeginImageContextWithOptions(self.image.size, NO, 1.0);
    [clippingPath addClip];
    [self.image drawAtPoint:CGPointZero];
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = CGImageCreateWithImageInRect([maskedImage CGImage], CGRectMake(clippingPath.bounds.origin.x,
                                                                                         clippingPath.bounds.origin.y,
                                                                                         clippingPath.bounds.size.width,
                                                                                         clippingPath.bounds.size.height));
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return img;
}

- (void) cropPuzzleGrip:(UIImage *)puzzleImage
{
    self.image = puzzleImage;
    self.puzzlePieceWidth = puzzleImage.size.width / self.puzzlesGridWidth;
    self.puzzlePieceHeight = puzzleImage.size.height / self.puzzlesGridHeight;
    for (NSInteger j = 0; j < self.puzzlesGridHeight; j++) { //self.puzzlesGridHeight
        for (NSInteger i = 0; i < self.puzzlesGridWidth ; i++) {//< self.puzzlesGridWidth
            UIBezierPath* bezierPath = [UIBezierPath bezierPath];
            [bezierPath moveToPoint: CGPointMake(i * self.puzzlePieceWidth, j * self.puzzlePieceHeight)];
            // Top line
            if(j == 0){
                [bezierPath addLineToPoint: CGPointMake((i + 1) * self.puzzlePieceWidth, j * self.puzzlePieceHeight)];
            }else if(j % 2 == 0){
                bezierPath = [self setFigureSide:i pathBefore:bezierPath withX:i  * self.puzzlePieceWidth withY:j * self.puzzlePieceHeight
                                        rotateOn:180  isReverse:true];
            }else{
                bezierPath = [self setFigureSide:i pathBefore:bezierPath withX:i  * self.puzzlePieceWidth withY:j * self.puzzlePieceHeight
                                        rotateOn:180  isReverse:false];
            }
            
            // Right line
            if(i == ([self puzzlesGridWidth] - 1)){
                [bezierPath addLineToPoint: CGPointMake((i + 1) * self.puzzlePieceWidth, (j + 1) * self.puzzlePieceHeight)];
            }else if(i % 2 == 0){
                bezierPath = [self setFigureSide:i pathBefore:bezierPath withX:(i + 1) * self.puzzlePieceWidth withY:j * self.puzzlePieceHeight
                                        rotateOn:90  isReverse:true];
            }else{
                bezierPath = [self setFigureSide:i pathBefore:bezierPath withX:((i + 1) * self.puzzlePieceWidth) withY:(j * self.puzzlePieceHeight)
                             rotateOn:90 isReverse:false];

            }
            // Bottom line
            if(j == ([self puzzlesGridHeight] - 1)){
                [bezierPath addLineToPoint: CGPointMake(i * self.puzzlePieceWidth, (j + 1) * self.puzzlePieceHeight)];
            }else if (j % 2 == 0){
                bezierPath = [self setFigureSide:i pathBefore:bezierPath withX:(i + 1) * self.puzzlePieceWidth withY:(j + 1) * self.puzzlePieceHeight rotateOn:0 isReverse:false];
            }else{
                bezierPath = [self setFigureSide:i pathBefore:bezierPath withX:(i + 1)  * self.puzzlePieceWidth withY:(j + 1) * self.puzzlePieceHeight rotateOn:0 isReverse:true];
            }
            // Left line
            if(i == 0){
                [bezierPath addLineToPoint: CGPointMake(i * self.puzzlePieceWidth, j * self.puzzlePieceHeight)];
            }else if (i % 2 == 0){
                bezierPath = [self setFigureSide:i pathBefore:bezierPath withX:i * self.puzzlePieceWidth withY:(j + 1) * self.puzzlePieceHeight rotateOn:-90 isReverse:false];
            }else{
                bezierPath = [self setFigureSide:i pathBefore:bezierPath withX:i * self.puzzlePieceWidth withY:(j + 1) * self.puzzlePieceHeight rotateOn:-90 isReverse:true];
            }
            [bezierPath setLineWidth:0.00001];
            [bezierPath closePath];
            
            [self.puzzlesArray addObject:[self setClippingPath:bezierPath cropImage:puzzleImage]];
            [self.coordinatesArray addObject:[NSValue valueWithCGRect:CGRectMake(bezierPath.bounds.origin.x,
                                                                                bezierPath.bounds.origin.y,
                                                                                bezierPath.bounds.size.width,
                                                                                bezierPath.bounds.size.height)]];
        }
    }
    
}
- (UIBezierPath *) setFigureSide:(NSInteger)pNum pathBefore:(UIBezierPath*)path withX:(CGFloat)startX withY:(CGFloat)startY rotateOn:(NSInteger)angle isReverse:(BOOL)reverse
{
    //Set side width for vertical or hirizontal side
    CGFloat sideWidth;
    NSInteger oper;
    if(reverse){
        oper = 1;
    }else{
        oper = -1;
    }
    switch (angle) {
        case 0:
            sideWidth = self.puzzlePieceWidth;
            [path addCurveToPoint:CGPointMake((startX - (sideWidth / 3)), (startY + (((sideWidth / 5) / 3) * oper)))
                    controlPoint1:CGPointMake(startX, startY)
                    controlPoint2:CGPointMake((startX - (sideWidth * 0.079)), (startY + (((sideWidth / 5) / 3) * oper)))];
            [path addCurveToPoint:CGPointMake((startX - (sideWidth / 2)), (startY - ((sideWidth / 5) * oper)))
                    controlPoint1:CGPointMake(startX - (sideWidth * 0.583), (startY + (((sideWidth / 5) / 3) * oper)))
                    controlPoint2:CGPointMake(startX - (sideWidth * 0.1702), (startY - ((sideWidth / 5) * oper)))];
            [path addCurveToPoint:CGPointMake((startX - (sideWidth * 2 / 3)), (startY + (((sideWidth / 5) / 3) * oper)))
                    controlPoint1:CGPointMake(startX - (sideWidth * 0.8232), (startY - ((sideWidth / 5) * oper)))
                    controlPoint2:CGPointMake(startX - (sideWidth * 0.4109), (startY + (((sideWidth / 5) / 3) * oper)))];
            [path addCurveToPoint:CGPointMake((startX  - sideWidth), startY)
                    controlPoint1:CGPointMake(startX - (sideWidth * 0.9136), (startY + (((sideWidth / 5) / 3) * oper)))
                    controlPoint2:CGPointMake((startX - sideWidth), startY)];
            break;
            
        case 90:
            sideWidth = self.puzzlePieceHeight;
            [path addCurveToPoint:CGPointMake((startX + (((sideWidth / 5) / 3) * oper)), (startY + (sideWidth / 3)))
                    controlPoint1:CGPointMake(startX, startY)
                    controlPoint2:CGPointMake((startX + (((sideWidth / 5) / 3) * oper)), (startY + (sideWidth * 0.079)))];
            [path addCurveToPoint:CGPointMake((startX - ((sideWidth / 5) * oper)), (startY + (sideWidth / 2)))
                    controlPoint1:CGPointMake((startX + (((sideWidth / 5) / 3) * oper)), startY + (sideWidth * 0.583))
                    controlPoint2:CGPointMake((startX - ((sideWidth / 5) * oper)), startY + (sideWidth * 0.1702))];
            [path addCurveToPoint:CGPointMake((startX + (((sideWidth / 5) / 3) * oper)), (startY + (sideWidth * 2 / 3)))
                    controlPoint1:CGPointMake((startX - ((sideWidth / 5) * oper)), startY + (sideWidth * 0.8232))
                    controlPoint2:CGPointMake((startX + (((sideWidth / 5) / 3) * oper)), startY + (sideWidth * 0.4109))];
            [path addCurveToPoint:CGPointMake(startX, (startY  + sideWidth))
                    controlPoint1:CGPointMake((startX + (((sideWidth / 5) / 3) * oper)), startY + (sideWidth * 0.9136))
                    controlPoint2:CGPointMake(startX, (startY + sideWidth))];
            break;
            
        case -90:
            sideWidth = self.puzzlePieceHeight;
            [path addCurveToPoint:CGPointMake((startX + (((sideWidth / 5) / 3) * oper)), (startY - (sideWidth / 3)))
                    controlPoint1:CGPointMake(startX, startY)
                    controlPoint2:CGPointMake((startX + (((sideWidth / 5) / 3) * oper)), (startY - (sideWidth * 0.079)))];
            [path addCurveToPoint:CGPointMake((startX - ((sideWidth / 5) * oper)), (startY - (sideWidth / 2)))
                    controlPoint1:CGPointMake((startX + (((sideWidth / 5) / 3) * oper)), startY - (sideWidth * 0.583))
                    controlPoint2:CGPointMake((startX - ((sideWidth / 5) * oper)), startY - (sideWidth * 0.1702))];
            [path addCurveToPoint:CGPointMake((startX + (((sideWidth / 5) / 3) * oper)), (startY - (sideWidth * 2 / 3)))
                    controlPoint1:CGPointMake((startX - ((sideWidth / 5) * oper)), startY - (sideWidth * 0.8232))
                    controlPoint2:CGPointMake((startX + (((sideWidth / 5) / 3) * oper)), startY - (sideWidth * 0.4109))];
            [path addCurveToPoint:CGPointMake(startX, (startY  - sideWidth))
                    controlPoint1:CGPointMake((startX + (((sideWidth / 5) / 3) * oper)), startY - (sideWidth * 0.9136))
                    controlPoint2:CGPointMake(startX, (startY - sideWidth))];
            break;
            
        case 180:
            sideWidth = self.puzzlePieceWidth;
            [path addCurveToPoint:CGPointMake((startX + (sideWidth / 3)), (startY + (((sideWidth / 5) / 3) * oper)))
                    controlPoint1:CGPointMake(startX, startY)
                    controlPoint2:CGPointMake((startX + (sideWidth * 0.079)), (startY + (((sideWidth / 5) / 3) * oper)))];
            [path addCurveToPoint:CGPointMake((startX + (sideWidth / 2)), (startY - ((sideWidth / 5) * oper)))
                    controlPoint1:CGPointMake(startX + (sideWidth * 0.583), (startY + (((sideWidth / 5) / 3) * oper)))
                    controlPoint2:CGPointMake(startX + (sideWidth * 0.1702), (startY - ((sideWidth / 5) * oper)))];
            [path addCurveToPoint:CGPointMake((startX + (sideWidth * 2 / 3)), (startY + (((sideWidth / 5) / 3) * oper)))
                    controlPoint1:CGPointMake(startX + (sideWidth * 0.8232), (startY - ((sideWidth / 5) * oper)))
                    controlPoint2:CGPointMake(startX + (sideWidth * 0.4109), (startY + (((sideWidth / 5) / 3) * oper)))];
            [path addCurveToPoint:CGPointMake((startX  + sideWidth), startY)
                    controlPoint1:CGPointMake(startX + (sideWidth * 0.9136), (startY + (((sideWidth / 5) / 3) * oper)))
                    controlPoint2:CGPointMake((startX + sideWidth), startY)];

            break;
            
    }
    return path;

}
@end
