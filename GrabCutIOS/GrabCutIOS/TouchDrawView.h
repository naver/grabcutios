//
//  TouchDrawView.h
//  OpenCVTest
//
//  Created by EunchulJeon on 2015. 8. 29..
//  Copyright (c) 2015 Naver Corp.
//  @Author Eunchul Jeon

//

#import <UIKit/UIKit.h>

typedef enum TouchState{
    TouchStateNone,
    TouchStateRect,
    TouchStatePlus,
    TouchStateMinus
}TouchState;

// Reference : http://code.tutsplus.com/tutorials/smooth-freehand-drawing-on-ios--mobile-13164

@interface TouchDrawView : UIView{
    CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    uint ctr;
}
@property (nonatomic, assign) TouchState currentState;
- (void) touchStarted:(CGPoint) p;
- (void) touchMoved:(CGPoint) p;
- (void) touchEnded:(CGPoint) p;
- (void) drawRectangle:(CGRect) rect;
- (void) clear;
- (UIImage *) maskImageWithPainting;
@end
