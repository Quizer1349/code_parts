//
//  PGCurveLabel.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 17.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGCurveLabel.h"
#import <CoreText/CoreText.h>

@implementation PGCurveLabel

@synthesize attString;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
   
    [super drawRect:rect];
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CGContextTranslateCTM(context, self.bounds.size.width/2, self.bounds.size.height/2);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, M_PI_2);
    
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attString);
    CFIndex glyphCount = CTLineGetGlyphCount(line);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runArray);
    
    NSMutableArray *widthArray = [[NSMutableArray alloc] init];
    
    CFIndex glyphOffset = 0;
    for (CFIndex i = 0; i < runCount; i++) {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, i);
        CFIndex runGlyphCount = CTRunGetGlyphCount((CTRunRef)run);
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
            NSNumber *widthValue = [NSNumber numberWithDouble:CTRunGetTypographicBounds((CTRunRef)run, CFRangeMake(runGlyphIndex, 1), NULL, NULL, NULL)];
            [widthArray insertObject:widthValue atIndex:(runGlyphIndex + glyphOffset)];
        }
        glyphOffset = runGlyphCount + 1;
    }
    
    CGFloat lineLength = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
    
    NSMutableArray *angleArray = [[NSMutableArray alloc] init];
    
    CGFloat prevHalfWidth =  [[widthArray objectAtIndex:0] floatValue] / 2.0;
    NSNumber *angleValue = [NSNumber numberWithDouble:(prevHalfWidth / lineLength) * M_PI];
    [angleArray insertObject:angleValue atIndex:0];
    
    for (CFIndex lineGlyphIndex = 1; lineGlyphIndex < glyphCount; lineGlyphIndex++) {
        CGFloat halfWidth = [[widthArray objectAtIndex:lineGlyphIndex] floatValue] / 2.0;
        CGFloat prevCenterToCenter = prevHalfWidth + halfWidth;
        NSNumber *angleValue = [NSNumber numberWithDouble:(prevCenterToCenter / lineLength) * M_PI_2];
        [angleArray insertObject:angleValue atIndex:lineGlyphIndex];
        prevHalfWidth = halfWidth;
    }
    
    CGPoint textPosition = CGPointMake(0.f, 50.f);
    CGContextSetTextPosition(context, textPosition.x, textPosition.y);
    
    glyphOffset = 0;
    
    for (CFIndex runIndex = 0; runIndex < runCount; runIndex++) {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CFIndex runGlyphCount = CTRunGetGlyphCount(run);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
            
            CFRange glyphRange = CFRangeMake(runGlyphIndex, 1);
            
            CGContextRotateCTM(context, [[angleArray objectAtIndex:(runGlyphIndex + glyphOffset)] floatValue]);
            
            CGFloat glyphWidth = [[widthArray objectAtIndex:(runGlyphIndex + glyphOffset)] floatValue];
            CGFloat halfGlyphWidth = glyphWidth / 2.0;
            CGPoint positionForThisGlyph = CGPointMake(textPosition.x - halfGlyphWidth, textPosition.y);
            
            textPosition.x -= glyphWidth;
            
            CGAffineTransform textMatrix = CTRunGetTextMatrix(run);
            textMatrix.tx = positionForThisGlyph.x; textMatrix.ty = positionForThisGlyph.y;
            CGContextSetTextMatrix(context, textMatrix);
            
            CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
            CGGlyph glyph; CGPoint position;
            CTRunGetGlyphs(run, glyphRange, &glyph);
            CTRunGetPositions(run, glyphRange, &position);
            
            CGContextSetFont(context, cgFont);
            CGContextSetFontSize(context, CTFontGetSize(runFont));
            
            CGContextSetRGBFillColor(context, 0.9, 0.9, 0.9, 1.0);
            CGContextShowGlyphsAtPositions(context, &glyph, &position, 1);
            
            CFRelease(cgFont);
        }
        glyphOffset += runGlyphCount;
        
    }
}


@end

